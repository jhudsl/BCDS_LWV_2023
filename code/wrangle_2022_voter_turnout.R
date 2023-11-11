library(tabulizer) # for extract_text() function
library(stringr) # for str_extract_all() function
# library(tidyverse)
# libary(magrittr)
library(data.table) # for data.table() function

# download all election results (from PDF)
download.file(url = "https://boe.baltimorecity.gov/sites/default/files/EL30%20GG%202022.pdf",
              destfile = "data/baltimore_city_precinct_results_2022.pdf")

# read all election results, as text
all_precinct_results <- extract_text("data/baltimore_city_precinct_results_2022.pdf")

# get names of precincts (three digits before the hyphen indicate the ward)
regex_for_precincts <- "\\d{3}-\\d{3}"
precinct_names <- unique(unlist(str_extract_all(all_precinct_results, regex_for_precincts)))

# set up data table of voter turnout by precinct
turnout_variables <- c("REGISTERED VOTERS - TOTAL",
                       "BALLOTS CAST - TOTAL",
                       "BALLOTS CAST - BLANK")
first_variable_after_turnout <- "Governor" # will not be included in this analysis, just used to stop the regex. make sure to choose a value that appears even when the total vote count is 0 (i.e., do not use "VOTER TURNOUT - TOTAL")
turnout_table <- as.data.table(expand.grid(Precinct = precinct_names,
                                           Registered = 0,
                                           `Total Ballots` = 0,
                                           `Blank Ballots` = 0))

# get raw voter turnout; use simple regex in this first step, for speed
# note about this regex: do not include regex_for_precincts because it will capture false matches
regex_for_raw_turnout <- paste(paste0(c(turnout_variables, first_variable_after_turnout), ".+?"), collapse = "")
raw_turnout_by_precinct <- unlist(str_extract_all(all_precinct_results,
                                                  regex(regex_for_raw_turnout,
                                                        dotall = T)))

# remove unrelated info from the text
clean_1precinct_turnout_result <- function(precinct_result_text, candidates, numeric_regex){
  regex <- paste(c(regex_for_precincts, paste0(candidates, numeric_regex)), collapse = "|")
  result_text <- unlist(str_extract_all(precinct_result_text, regex))
  result_text <- result_text[result_text != ""]
  return(result_text)
}
cleaned_turnout_by_precinct <- lapply(raw_turnout_by_precinct,
                                      clean_1precinct_turnout_result,
                                      candidates = turnout_variables,
                                      numeric_regex = ".+?\\d+")
rm(raw_turnout_by_precinct, regex_for_raw_turnout)

# add all turnout results to table

add_1precinct_turnout_to_table <- function(result_text, precinct){
  turnout_table[Precinct == precinct,
                `:=`(Registered = as.numeric(str_extract(result_text[1], "\\d+")),
                     `Total Ballots` = as.numeric(str_extract(result_text[2], "\\d+")),
                     `Blank Ballots` = as.numeric(str_extract(result_text[3], "\\d+")))]
  return(0)
}
success <- sapply(1:(length(precinct_names)-1), function(i) add_1precinct_turnout_to_table(result_text = cleaned_turnout_by_precinct[[i]],
                                                                                       precinct = precinct_names[i]))
rm(success, cleaned_turnout_by_precinct)

# preview the data
head(turnout_table)