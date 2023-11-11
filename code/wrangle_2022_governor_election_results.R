library(tabulizer) # for extract_text() function
library(stringr) # for str_extract_all() function
library(data.table) # for data.table() function

# download all election results (from PDF)
download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
              destfile = "data/input/public/baltimore_city_precincts_general_election_results_2022.pdf")

# read all election results, as text
all_precinct_results <- extract_text("data/input/public/baltimore_city_precincts_general_election_results_2022.pdf")

# get names of precincts (three digits before the hyphen indicate the ward)
regex_for_precincts <- "\\d{3}-\\d{3}"
precinct_names <- unique(unlist(str_extract_all(all_precinct_results, regex_for_precincts)))

# set up data table of election results
governor_candidates <- c("Cox-Schifanelli", "Moore-Miller", "Lashar-Logansmith", "Wallace-Elder", "Harding-White", "WRITE-IN")
first_variable_after_candidates <- "Over Votes" # will not be included in this analysis, just used to stop the regex. make sure to choose a value that appears even when the total vote count is 0 (i.e., do not use "Total")
governor_parties <- c("REP", "DEM", "LIB", "GRN", "WCP", NA)
governor_table <- data.table(Election = "Governor",
                             Candidate = governor_candidates,
                             Party = governor_parties)
election_results_table <- as.data.table(expand.grid(Precinct = precinct_names,
                                               Candidate = governor_candidates,
                                               Votes = 0))
election_results_table <- governor_table[election_results_table, on = .(Candidate)]

# get raw governor election results; use simple regex in this first step, for speed
# note 1 about this regex: all precincts report all candidates' performance, even if some candidates got 0 votes (though such candidates' percent isn't reported)
# note 2 about this regex: do not include regex_for_precincts because it will capture false matches
regex_for_raw_governor_election_results <- paste0(c(governor_candidates, first_variable_after_candidates), collapse = ".+?")
raw_governor_results_by_precinct <- unlist(str_extract_all(all_precinct_results,
                                                           regex(regex_for_raw_governor_election_results,
                                                                 dotall = T)))

# remove unrelated info from the text
# note: we choose to extract only the number of votes, not the percent (regex for including votes and percent would be ".+?\\d+ +\\d*\\.\\d+"; this would return character(0) for candidates who received 0 votes)
# because percent isn't reported for candidates who received 0 votes; this would especially pose a problem for a precinct where no one voted
clean_1precinct_election_result <- function(precinct_result_text, candidates){
  regex <- paste(paste0(candidates, ".+?\\d+ "), collapse = "|")
  result_text <- unlist(str_extract_all(precinct_result_text, regex))
  result_text <- result_text[result_text != ""]
  return(result_text)
}
cleaned_governor_results_by_precinct <- lapply(raw_governor_results_by_precinct,
                                               clean_1precinct_election_result,
                                               candidates = governor_candidates)
rm(raw_governor_results_by_precinct, regex_for_raw_governor_election_results)

# add all governor election results to table
add_1precinct_to_table <- function(result_text, precinct, candidates){
  if (length(result_text) > 0){ # a fail-safe
    for (i in 1:length(result_text)){
      candidate <- str_extract(result_text[i], "[A-z\\-]+") # need to extract candidate because not all candidates will be included in this step; see previous step's comment
      votes <- as.numeric(str_extract(result_text[i], "\\d+"))
      percent_of_vote <- as.numeric(str_extract(result_text[i], "\\d*\\.\\d+"))
      election_results_table[Precinct == precinct & Election == "Governor" & Candidate == candidate,
                             `:=`(Votes = votes)]
    }
  }
  return(0)
}
success <- sapply(1:length(precinct_names), function(i) add_1precinct_to_table(result_text = cleaned_governor_results_by_precinct[[i]],
                                                                               precinct = precinct_names[i],
                                                                               candidates = governor_candidates))
rm(success, cleaned_governor_results_by_precinct)

# preview the data
head(election_results_table)

# save the data
fwrite(election_results_table, file = "data/intermediate/public/baltimore_city_governor_2022_general_election_results.csv")
