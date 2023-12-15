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
            Voted_Female = sum(Voted_Female, na.rm = T),
            Voted_Male = sum(Voted_Male, na.rm = T),
            Voted_UnknownSex = sum(Voted_UnknownSex, na.rm = T),
            Voted_16to17 = sum(Voted_16to17, na.rm = T),
            Voted_18to24 = sum(Voted_18to24, na.rm = T),
            Voted_25to34 = sum(Voted_25to34, na.rm = T),
            Voted_35to44 = sum(Voted_35to44, na.rm = T),
            Voted_45to54 = sum(Voted_45to54, na.rm = T),
            Voted_55to64 = sum(Voted_55to64, na.rm = T),
            Voted_65plus = sum(Voted_65plus, na.rm = T),
            .by = Legislative) %>%
  mutate(Registered_of_Adjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Turnout_of_Registered = round(`BALLOTS CAST - TOTAL` / `REGISTERED VOTERS - TOTAL` * 100, 2),
         Turnout_of_Adjusted_Adults = round(`BALLOTS CAST - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
         Early_of_Voted = round(`Early Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Election_Night_of_Voted = round(`Election Night Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         MailIn1_of_Voted = round(`Mail-In Ballot 1 Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Provisional_of_Voted = round(`Provisional Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         MailIn2_of_Voted = round(`Mail-In Ballot 2 Votes` / `BALLOTS CAST - TOTAL` * 100, 2),
         Hispanic_Latino_of_Adjusted_Adults = round(Adjusted_Hispanic_Latino_Adult_Pop / Adjusted_Total_Adult_Pop, 2),
         Female_of_Voted = round(Voted_Female / `BALLOTS CAST - TOTAL` * 100, 2),
         Male_of_Voted = round(Voted_Male / `BALLOTS CAST - TOTAL` * 100, 2),
         UnknownSex_of_Voted = round(Voted_UnknownSex / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages16to17_of_Voted = round(Voted_16to17 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages18to24_of_Voted = round(Voted_18to24 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages25to34_of_Voted = round(Voted_25to34 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages35to44_of_Voted = round(Voted_35to44 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages45to54_of_Voted = round(Voted_45to54 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages55to64_of_Voted = round(Voted_55to64 / `BALLOTS CAST - TOTAL` * 100, 2),
         Ages65plus_of_Voted = round(Voted_65plus / `BALLOTS CAST - TOTAL` * 100, 2))

# save aggregated dataset
write_csv(legislative_district_data, file = paste0(dir, "data/final/public/Baltimore_City/general_election_2022/merged_data_legislative_districts.csv"))
