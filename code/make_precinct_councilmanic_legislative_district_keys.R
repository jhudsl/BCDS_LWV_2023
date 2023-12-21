library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# get 2020 precinct-to-legislative-district correspondence from Maryland government's Green Book (adjusted 2020 population table)
# note that Maryland's state legislative districts changed from 2020 to 2022 following the 2020 census (https://ballotpedia.org/Redistricting_in_Maryland_after_the_2020_census)
# for simplicity, use one of the cleaned datasets in data/intermediate/ folder
adjusted_adult_population_2020 <- read_csv(paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# get 2020 precinct-to-councilmanic (= city council)-district correspondence from 2022 voter file
# note that city council districts did not change from 2020 to 2023 (https://www.baltimoresun.com/2023/10/20/baltimore-city-council-approves-council-president-nick-mosbys-redistricting-map-mayors-office-says-it-will-review/)
# for simplicity, use one of the cleaned datasets in data/intermediate/ folder
registered_voters_2022 <- read_csv(paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_2022-11-08/registered_voters_age.csv"))

# note: if we wanted the 2022 precinct-to-legislative district correspondence, we would use registered_voters_2022's LEGISLATIVE_DISTRICTS column
# the voter file's districts reflect the year in which the voter file was requested (2023, or 2022 if there is a lag)

# make table(s) of precinct to councilmanic and legislative districts
precinct_to_2020_legislative_district <- adjusted_adult_population_2020 %>%
  select(Precinct, Legislative) %>%
  unique()
precinct_to_2020_councilmanic_district <- registered_voters_2022 %>%
  rename(Precinct = PRECINCT, Councilmanic = COUNCILMANIC_DISTRICTS) %>%
  mutate(Precinct = ifelse(nchar(Precinct) == 4, paste0("00", Precinct), paste0("0", Precinct))) %>% # zero-pad the precinct
  mutate(Precinct = paste0(substr(Precinct, 1, 3), "-", substr(Precinct, 4, 6))) %>% # use {3 digit ward}-{3 digit precinct within ward} naming convention for precinct
  select(Precinct, Councilmanic) %>%
  unique()

# save resulting table(s)
write_csv(precinct_to_2020_legislative_district, file = paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2020_legislative_district_key.csv"))
write_csv(precinct_to_2020_councilmanic_district, file = paste0(dir, "data/intermediate/public/Baltimore_City/precinct_to_2020_councilmanic_district_key.csv"))
