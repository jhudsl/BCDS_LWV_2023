library(tabulizer) # for extract_text() function
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results (from online PDF)
# download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
#               destfile = paste0(dir, "data/input/public/baltimore_city_precincts_general_election_results_2022.pdf"))

# read all election results, as text
all_precinct_results <- extract_text(paste0(dir, "data/input/public/baltimore_city_precincts_general_election_results_2022.pdf"))

# get names of precincts (three digits before the hyphen indicate the ward)
regex_for_precincts <- "\\d{3}-\\d{3}"
precinct_names <- unique(unlist(str_extract_all(all_precinct_results, regex_for_precincts)))

# parse election results
results_line_by_line <- unlist(str_split(all_precinct_results, "\n"))

turnout_variables <- c("REGISTERED VOTERS - TOTAL",
                       "BALLOTS CAST - TOTAL",
                       "BALLOTS CAST - BLANK")
governor_candidates <- c("Cox-Schifanelli",
                         "Moore-Miller",
                         "Lashar-Logansmith",
                         "Wallace-Elder",
                         "Harding-White",
                         "WRITE-IN")

parse_turnout_results <- function(variable){
  results_as_text <- results_line_by_line[grepl(variable, results_line_by_line)]
  
  results_as_tibble <- tibble(temp = results_as_text) %>%
    mutate(Precinct = precinct_names,
           Variable = str_extract(temp, "[A-z\\- ]+"),
           Count = str_extract(temp, "\\d+"),
           temp = NULL)
}

parse_candidate_results <- function(candidate, election_number_in_report){
  results_as_text <- results_line_by_line[grepl(candidate, results_line_by_line)]
  
  if (candidate == "WRITE-IN"){ # "WRITE-IN" is an option in every government office being voted on, so filter to the correct one
    election_indices <- rep(FALSE, 14) # there are 14 elections (aka races aka government offices being voted on) in this report
    election_indices[election_number_in_report] <- TRUE
    results_as_text <- results_as_text[election_indices] # keep 1 in every 14 "WRITE-IN" regex matches
  }
  
  results_as_tibble <- tibble(temp = results_as_text) %>%
    mutate(Precinct = precinct_names,
           Candidate = str_extract(temp, "[A-z\\- ()]+"), # "()" includes candidates' party affiliation, which is enclosed in parentheses
           Votes = str_extract(temp, "\\d+"),
           temp = NULL)
}

turnout_results <- lapply(turnout_variables, parse_turnout_results) %>%
  bind_rows()
governor_results <- lapply(governor_candidates, parse_candidate_results, election_number_in_report = 1) %>%
  bind_rows()



# preview the data
head(turnout_results)
head(governor_results)

# save the data
write_csv(turnout_results, file = paste0(dir, "data/intermediate/public/baltimore_city_2022_general_election_turnout_results.csv"))
write_csv(governor_results, file = paste0(dir, "data/intermediate/public/baltimore_city_2022_general_election_governor_results.csv"))
