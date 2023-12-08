library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# read in data
precinct_populations_and_turnout <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/merged_data_GeneralElection2022_Population2020.csv"))
precinct_to_legislative_district <- read_csv(file = paste0(dir, "data/input/public/Baltimore_City/precinct_to_legislative_district_key.csv"))

# aggregate from precinct to [state] legislative district
# save only population variables, not broken down by race (not interested in race variables at the moment)
legislative_districts_populations_and_turnout <- precinct_populations_and_turnout %>%
  full_join(precinct_to_legislative_district) %>%
  summarize(`REGISTERED VOTERS - TOTAL` = sum(`REGISTERED VOTERS - TOTAL`, na.rm = T),
            `BALLOTS CAST - TOTAL` = sum(`BALLOTS CAST - TOTAL`, na.rm = T),
            `BALLOTS CAST - BLANK` = sum(`BALLOTS CAST - BLANK`, na.rm = T),
            Census_Total_Pop = sum(Census_Total_Pop, na.rm = T),
            Adjusted_Total_Pop = sum(Adjusted_Total_Pop, na.rm = T),
            Census_Total_Adult_Pop = sum(Census_Total_Adult_Pop, na.rm = T),
            Adjusted_Total_Adult_Pop = sum(Adjusted_Total_Adult_Pop, na.rm = T),
            .by = Legislative) %>%
  mutate(Registered_of_Adjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Turnout_of_Registered = round(`BALLOTS CAST - TOTAL` / `REGISTERED VOTERS - TOTAL` * 100, 2),
         Turnout_of_Adjusted_Adults = round(`BALLOTS CAST - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Registered_of_Unadjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Census_Total_Adult_Pop * 100, 2),
         Turnout_of_Unadjusted_Adults = round(`BALLOTS CAST - TOTAL` / Census_Total_Adult_Pop * 100, 2))

# to do: deal with NAs, reconcile adjusted vs unadjusted

# save aggregated dataset
write_csv(legislative_districts_populations_and_turnout, file = paste0(dir, "data/final/public/Baltimore_City/general_election_2022/legislative_districts_population_and_turnout.csv"))


