library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results (from online PDF)
# download.file(url = "https://elections.maryland.gov/elections/2022/election_data/GG22_03PrecinctsResults.csv",
#               destfile = paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# read all election results, as csv
all_precinct_results <- read_csv(paste0(dir, "data/input/public/Baltimore_City/general_election_2022/precinct_results_including_ballot_type.csv"))

# create new column(s)
all_precinct_results <- all_precinct_results %>% mutate(`Total Votes` = `Early Votes` + `Election Night Votes` +
                                                          `Mail-In Ballot 1 Votes` + `Mail-In Ballot 2 Votes` +
                                                          `Provisional Votes`)

# save the resulting data table(s)
write_csv(all_precinct_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))
