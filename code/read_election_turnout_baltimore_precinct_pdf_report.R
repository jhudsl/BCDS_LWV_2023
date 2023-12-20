library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results, including voter turnout and blank ballots by precinct (a PDF)
# download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
#               destfile = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_turnout.pdf"))

# read all election results, as text (creates 1 large character)
# extract_tables() would be hard to use because each page contains multiple tables and we want to pull only some of them
# therefore, use extract_text()
all_precinct_results <- extract_text(file = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_turnout.pdf"))

# get names of precincts (FYI, three digits before the hyphen indicate the ward)
regex_for_precincts <- "\\d{3}-\\d{3}"
precinct_names <- unique(unlist(str_extract_all(string = all_precinct_results,
                                                pattern = regex_for_precincts)))

# prepare to parse the PDF by dividing it by newlines ("\n") (creates character vector)
results_line_by_line <- unlist(str_split(string = all_precinct_results,
                                         pattern = "\n"))

# set names of candidates for each election (office being voted on)
turnout_variables <- c("REGISTERED VOTERS - TOTAL",
                       "BALLOTS CAST - TOTAL",
                       "BALLOTS CAST - BLANK")

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

# parse!
turnout_results <- lapply(turnout_variables,
                          parse_turnout_results) %>%
  bind_rows()

# save the resulting data table(s)
write_csv(turnout_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/election_turnout_results.csv"))
