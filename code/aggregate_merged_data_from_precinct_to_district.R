library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# read in data
precinct_data <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/merged_data_precincts.csv"))

# aggregate from precinct to [state] legislative district
legislative_district_data <- precinct_data %>%
  summarize(`REGISTERED VOTERS - TOTAL` = sum(`REGISTERED VOTERS - TOTAL`, na.rm = T),
            `BALLOTS CAST - TOTAL` = sum(`BALLOTS CAST - TOTAL`, na.rm = T),
            `BALLOTS CAST - BLANK` = sum(`BALLOTS CAST - BLANK`, na.rm = T),
            Adjusted_Total_Pop = sum(Adjusted_Total_Pop, na.rm = T),
            Adjusted_Total_Adult_Pop = sum(Adjusted_Total_Adult_Pop, na.rm = T),
            Adjusted_Hispanic_Latino_Adult_Pop = sum(Adjusted_Hispanic_Latino_Adult_Pop, na.rm = T),
            `Early Votes` = sum(`Early Votes`, na.rm = T),
            `Election Night Votes` = sum(`Election Night Votes`, na.rm = T),
            `Mail-In Ballot 1 Votes` = sum(`Mail-In Ballot 1 Votes`, na.rm = T),
            `Provisional Votes` = sum(`Provisional Votes`, na.rm = T),
            `Mail-In Ballot 2 Votes` = sum(`Mail-In Ballot 2 Votes`, na.rm = T),
            .by = Legislative) %>%
  mutate(Registered_of_Adjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Turnout_of_Registered = round(`BALLOTS CAST - TOTAL` / `REGISTERED VOTERS - TOTAL` * 100, 2),
         Turnout_of_Adjusted_Adults = round(`BALLOTS CAST - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Early_of_Voted = round(`Early Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Election_Night_of_Voted = round(`Election Night Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         MailIn1_of_Voted = round(`Mail-In Ballot 1 Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Provisional_of_Voted = round(`Provisional Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         MailIn2_of_Voted = round(`Mail-In Ballot 2 Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Hispanic_Latino_of_Adjusted_Adults = round(Adjusted_Hispanic_Latino_Adult_Pop / Adjusted_Total_Adult_Pop, 2))

# save aggregated dataset
write_csv(legislative_district_data, file = paste0(dir, "data/final/public/Baltimore_City/general_election_2022/merged_data_legislative_districts.csv"))
