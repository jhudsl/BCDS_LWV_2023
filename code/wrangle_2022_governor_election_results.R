library(tabulizer) # for extract_text() function
library(stringr) # for str_extract_all() function
library(data.table) # for data.table() function

# get all election results, as text
download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
              destfile = "data/baltimore_city_precinct_results_2022.pdf")
all_precinct_results <- extract_text("data/baltimore_city_precinct_results_2022.pdf")

# get names of precincts (three digits before the hyphen indicate the ward)
precinct_names <- unique(unlist(str_extract_all(all_precinct_results, "\\d{3}-\\d{3}")))

# set up data table of election results
governor_candidates <- c("Cox-Schifanelli", "Moore-Miller", "Lashar-Logansmith", "Wallace-Elder", "Harding-White", "WRITE-IN")
governor_parties <- c("REP", "DEM", "LIB", "GRN", "WCP", NA)
governor_table <- data.table(Election = "Governor",
                             Candidate = governor_candidates,
                             Party = governor_parties)
all_results_table <- as.data.table(expand.grid(Precinct = precinct_names,
                                               Candidate = governor_candidates,
                                               Votes = -1, # placeholder value
                                               Percent = -1)) # placeholder value
all_results_table <- governor_table[all_results_table, on = .(Candidate)]

# get governor election results
raw_governor_results_by_precinct <- unlist(str_extract_all(all_precinct_results, regex(paste(paste0(c(governor_candidates, "Total"), ".+?"), collapse = ""), dotall = T)))

# remove non-governor election info from the text
clean_1precinct_election_result <- function(precinct_result_text, candidates){
  regex <- paste(paste0(candidates, ".+?\\d+ +\\d*\\.\\d+|"), collapse = "")
  result_text <- unlist(str_extract_all(precinct_result_text, regex))
  result_text <- result_text[result_text != ""]
  return(result_text)
}
cleaned_governor_results_by_precinct <- lapply(raw_governor_results_by_precinct, clean_1precinct_election_result, candidates = governor_candidates)
rm(raw_governor_results_by_precinct)

# add all governor election results to table
add_1precinct_to_table <- function(result_text, precinct, candidates){
  for (i in 1:length(result_text)){
    candidate <- str_extract(result_text[i], "[A-z\\-]+")
    votes <- as.numeric(str_extract(result_text[i], "\\d+"))
    percent_of_vote <- as.numeric(str_extract(result_text[i], "\\d*\\.\\d+"))
    all_results_table[Precinct == precinct & Election == "Governor" & Candidate == candidate, `:=`(Votes = votes,
                                                                                                   Percent = percent_of_vote)]
  }
  return(0)
}
success <- sapply(1:length(precinct_names), function(i) add_1precinct_to_table(result_text = cleaned_governor_results_by_precinct[[i]], precinct = precinct_names[i], candidates = governor_candidates))
rm(success, cleaned_governor_results_by_precinct)

# preview the data
head(all_results_table)