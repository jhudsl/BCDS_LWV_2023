library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results, including breakdowns by ballot type, e.g., mail-in (already a csv)
# download.file(url = "https://elections.maryland.gov/elections/2022/election_data/GG22_03PrecinctsResults.csv",
#               destfile = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# read all election results, as csv
all_precinct_results <- read_csv(file = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# in the raw dataset, "Votes" means "Votes For", so rename columns to be clearer
all_precinct_results <- all_precinct_results %>%
  rename(Precinct = `Election District - Precinct`,
         `Early Votes for Candidate` = `Early Votes`,
         `Election Night Votes for Candidate` = `Election Night Votes`,
         `Mail-In Ballot 1 Votes for Candidate` = `Mail-In Ballot 1 Votes`,
         `Mail-In Ballot 2 Votes for Candidate` = `Mail-In Ballot 2 Votes`,
         `Provisional Votes for Candidate` = `Provisional Votes`) %>%
  select(-`Office District`) # Office District is redundant with "Congressional [District]" and "Legislative [District]"

# create new columns for each candidate in each precinct
all_precinct_results <- all_precinct_results %>%
  rowwise() %>%
  mutate(`Total Votes For Candidate` = sum(`Early Votes for Candidate`,
                                           `Election Night Votes for Candidate`,
                                           `Mail-In Ballot 1 Votes for Candidate`,
                                           `Mail-In Ballot 2 Votes for Candidate`,
                                           `Provisional Votes for Candidate`,
                                           na.rm = T),
         `Total Votes Against` = sum(`Early Votes Against`,
                                     `Election Night Votes Against`,
                                     `Mail-In Ballot 1 Votes Against`,
                                     `Mail-In Ballot 2 Votes Against`,
                                     `Provisional Votes Against`,
                                     na.rm = T),
         `Total Votes Cast` = sum(`Total Votes For Candidate`,
                                  `Total Votes Against`,
                                  na.rm = T)) %>%
  ungroup() # no longer rowwise()

# calculate total number of votes in each office being elected (combining all candidates), by ballot type
results_by_office_and_ballot_type <- all_precinct_results %>%
  group_by(County,
           `County Name`,
           Precinct,
           Congressional,
           Legislative,
           `Office Name`) %>%
  summarize(`Early Votes For` = sum(`Early Votes for Candidate`),
            `Early Votes Against` = sum(`Early Votes Against`),
            `Election Night Votes For` = sum(`Election Night Votes for Candidate`),
            `Election Night Votes Against` = sum(`Election Night Votes Against`),
            `Mail-In Ballot 1 Votes For` = sum(`Mail-In Ballot 1 Votes for Candidate`),
            `Mail-In Ballot 1 Votes Against` = sum(`Mail-In Ballot 1 Votes Against`),
            `Provisional Votes For` = sum(`Provisional Votes for Candidate`),
            `Provisional Votes Against` = sum(`Provisional Votes Against`),
            `Mail-In Ballot 2 Votes For` = sum(`Mail-In Ballot 2 Votes for Candidate`),
            `Mail-In Ballot 2 Votes Against` = sum(`Mail-In Ballot 2 Votes Against`)) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(`Early Votes` = sum(`Early Votes For`, `Early Votes Against`, na.rm = T),
         `Election Night Votes` = sum(`Election Night Votes For`, `Election Night Votes Against`, na.rm = T),
         `Mail-In Ballot 1 Votes` = sum(`Mail-In Ballot 1 Votes For`, `Mail-In Ballot 1 Votes Against`, na.rm = T),
         `Provisional Votes` = sum(`Provisional Votes For`, `Provisional Votes Against`, na.rm = T),
         `Mail-In Ballot 2 Votes` = sum(`Mail-In Ballot 2 Votes For`, `Mail-In Ballot 2 Votes Against`, na.rm = T)) %>%
  ungroup()

# count number of ballot type in each precinct by taking max across elected offices
precinct_ballot_types <- results_by_office_and_ballot_type %>%
  group_by(County,
           `County Name`,
           Precinct,
           Congressional,
           Legislative) %>%
  summarize(`Early Votes` = max(`Early Votes`, na.rm = T),
         `Election Night Votes` = max(`Election Night Votes`, na.rm = T),
         `Mail-In Ballot 1 Votes` = max(`Mail-In Ballot 1 Votes`, na.rm = T),
         `Provisional Votes` = max(`Provisional Votes`, na.rm = T),
         `Mail-In Ballot 2 Votes` = max(`Mail-In Ballot 2 Votes`, na.rm = T)) %>%
  ungroup()

# save the resulting data table(s)
write_csv(all_precinct_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/results_by_office_and_ballot_type.csv"))
write_csv(results_by_office_and_ballot_type, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/turnout_by_office_and_ballot_type.csv"))
write_csv(precinct_ballot_types, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/turnout_by_ballot_type.csv"))
