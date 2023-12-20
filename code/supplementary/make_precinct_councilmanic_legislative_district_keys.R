library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# read 2022 election results, from Maryland Board of Elections
all_precinct_results <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/candidate_results_by_ballot_type.csv"))

# read adjusted 2020 population table (from Maryland government's Green Book)
adjusted_adult_population_2020 <- read_csv(paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# make table(s) of precinct to legislative district
precinct_to_2022legislative_district <- all_precinct_results %>%
  select(Precinct, Legislative) %>%
  unique()
precinct_to_2020legislative_district <- adjusted_adult_population_2020 %>%
  select(Precinct, Legislative) %>%
  unique()

# save resulting table(s)
write_csv(precinct_to_2022legislative_district, file = paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2022legislative_district_key.csv"))
write_csv(precinct_to_2020legislative_district, file = paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2020legislative_district_key.csv"))
