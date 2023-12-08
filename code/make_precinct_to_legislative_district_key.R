library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# read all election results
all_precinct_results <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))

# make table of precinct to legislative district
precinct_to_legislative_district <- all_precinct_results %>%
  select(`Election District - Precinct`, Legislative) %>%
  unique() %>%
  rename(Precinct = `Election District - Precinct`)

# save resulting table
write_csv(precinct_to_legislative_district, file = paste0(dir, "data/input/public/Baltimore_City/precinct_to_legislative_district_key.csv"))
