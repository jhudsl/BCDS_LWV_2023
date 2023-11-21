library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results (from online PDF)
# download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
#               destfile = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_turnout.pdf"))

# read all election results, as text
all_precinct_results <- extract_text(paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_turnout.pdf"))

# get names of precincts (FYI, three digits before the hyphen indicate the ward)
regex_for_precincts <- "\\d{3}-\\d{3}"
precinct_names <- unique(unlist(str_extract_all(string = all_precinct_results,
                                                pattern = regex_for_precincts)))

# set names of candidates for each election (office being voted on)
results_line_by_line <- unlist(str_split(string = all_precinct_results,
                                         pattern = "\n"))

turnout_variables <- c("REGISTERED VOTERS - TOTAL",
                       "BALLOTS CAST - TOTAL",
                       "BALLOTS CAST - BLANK")
governor_candidates <- c("Cox-Schifanelli",
                         "Moore-Miller",
                         "Lashar-Logansmith",
                         "Wallace-Elder",
                         "Harding-White",
                         "WRITE-IN")
us_senator_candidates <- c("Chris Chaffee",
                           "Chris Van Hollen",
                           "WRITE-IN")

# function to parse voter turnout for each precinct
parse_turnout_results <- function(variable){
  results_as_text <- str_extract(string = results_line_by_line,
                                 pattern = paste0(variable, ".+?\\d+")) # extract the variable name and the counts
  results_as_text <- results_as_text[!is.na(results_as_text)]
  
  results_as_tibble <- tibble(text = results_as_text) %>%
    mutate(Precinct = precinct_names,
           Variable = variable,
           Count = str_extract(text, "\\d+"), # extract the number
           text = NULL)
  return(results_as_tibble)
}

# function to parse results of each election (office being voted on)
parse_candidate_results <- function(candidate, all_candidates){
  if (candidate == "WRITE-IN"){
    # every election (office being voted on) has "WRITE-IN" as a candidate, so need extra filtering
    all_write_in_indices <- grep(pattern = "WRITE-IN",
                                 x = results_line_by_line)
    
    # trick: to identify which WRITE-IN we want, use the last candidate in the election (office being voted on) we want
    last_candidate <- all_candidates[length(all_candidates) - 1]
    last_candidate_indices <- grep(pattern = last_candidate,
                                   x = results_line_by_line)
    write_in_indices <- last_candidate_indices + 1 # WRITE-IN should be in the line after the last candidate
    
    # except, if there is a page break, then WRITE-IN will be 3 lines instead of 1 line after the last candidate
    for (i in 1:length(write_in_indices)){
      if (!(write_in_indices[i] %in% all_write_in_indices) &
          (write_in_indices[i] + 2 %in% all_write_in_indices)){ # +2 if new page
        write_in_indices[i] <- write_in_indices[i] + 2
      }
    }
    
    # now we can pull the text! (there is a vulnerability here in that it's possible that both columns in this row are WRITE-IN, in which case we'd be taking the left column)
    results_as_text <- str_extract(string = results_line_by_line[write_in_indices],
                                   pattern = paste0("WRITE-IN", ".+?\\d+")) # extract the variable name and the counts
  } else{
    # for registered candidates, we can do the usual str_extract() call
    results_as_text <- str_extract(string = results_line_by_line,
                                   pattern = paste0(candidate, ".+?\\d+")) # extract the variable name and the counts
    results_as_text <- results_as_text[!is.na(results_as_text)]
    
  }
  
  # parse and put the results in a table
  results_as_tibble <- tibble(text = results_as_text) %>%
    mutate(Precinct = precinct_names,
           Candidate = candidate,
           Affiliation = str_extract(text, "\\([A-z]+\\)"), # extract the text enclosed in parentheses
           Votes = str_extract(text, "\\d+"), # extract the number
           text = NULL) %>%
    mutate(Affiliation = str_remove_all(Affiliation, "\\(|\\)")) # remove the parentheses
  return(results_as_tibble)
}

# parse!
turnout_results <- lapply(turnout_variables,
                          parse_turnout_results) %>%
  bind_rows()
governor_results <- lapply(governor_candidates,
                           parse_candidate_results,
                           all_candidates = governor_candidates) %>%
  bind_rows()
us_senator_results <- lapply(us_senator_candidates,
                             parse_candidate_results,
                             all_candidates = us_senator_candidates) %>%
  bind_rows()

# save the resulting data tables
write_csv(turnout_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/election_turnout_results.csv"))
write_csv(governor_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/governor_results.csv"))
write_csv(us_senator_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/us_senator_results.csv"))
