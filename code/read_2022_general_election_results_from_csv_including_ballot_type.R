library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results, including breakdowns by ballot type, e.g., mail-in (already a csv)
# download.file(url = "https://elections.maryland.gov/elections/2022/election_data/GG22_03PrecinctsResults.csv",
#               destfile = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# read all election results, as csv
all_precinct_results <- read_csv(file = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# NOTE: in the raw dataset, "Votes" means "Votes For"
# rename columns to be clearer
all_precinct_results <- all_precinct_results %>%
  rename(`Early Votes for Candidate` = `Early Votes`,
         `Election Night Votes for Candidate` = `Election Night Votes`,
         `Mail-In Ballot 1 Votes for Candidate` = `Mail-In Ballot 1 Votes`,
         `Mail-In Ballot 2 Votes for Candidate` = `Mail-In Ballot 2 Votes`,
         `Provisional Votes for Candidate` = `Provisional Votes`)

# create new columns
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
                                  na.rm = T))

# save the resulting data table(s)
write_csv(all_precinct_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))
