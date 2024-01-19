library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# get 2020 precinct-to-legislative-district and 2020 precinct-to-councilmanic-district keys
precinct_to_legislative_key <- read_csv(paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2020_legislative_district_key.csv"))
precinct_to_councilmanic_key <- read_csv(paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2020_councilmanic_district_key.csv"))

# get aggregated merged data
legislative_aggregated_data <- read_csv(paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/merged_data_legislative_districts.csv"))
councilmanic_aggregated_data <- read_csv(paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/merged_data_councilmanic_districts.csv"))

# merge in precincts
# result is that the district-wide variables will be repeated across the rows of precincts in each district
legislative_data_with_precinct <- legislative_aggregated_data %>%
  left_join(precinct_to_legislative_key) %>%
  mutate(Precinct = paste0(substr(Precinct, 2, 7))) # use {2 digit ward}-{3 digit precinct within ward} naming convention for precinct, because that's what the shapefile uses

councilmanic_data_with_precinct <- councilmanic_aggregated_data %>%
  left_join(precinct_to_councilmanic_key) %>%
  mutate(Precinct = paste0(substr(Precinct, 2, 7))) # use {2 digit ward}-{3 digit precinct within ward} naming convention for precinct, because that's what the shapefile uses

# save resulting dataset(s)
write_csv(legislative_data_with_precinct, file = paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/merged_data_legislative_districts_with_precinct.csv"))
write_csv(councilmanic_data_with_precinct, file = paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/merged_data_councilmanic_districts_with_precinct.csv"))
