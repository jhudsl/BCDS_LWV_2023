library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"


# read all election results
all_precinct_results <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))

# to do: aggregate from precincts to city council districts (= councilmanic districts)
# to do: find conversion from election precinct to city council district
# all_councilmanic_district_results


# aggregate from precincts to [state] legislative districts
all_legislative_district_results <- all_precinct_results %>%
  summarize(`Early Votes for Candidate` = sum(`Early Votes for Candidate`),
            `Early Votes Against` = sum(`Early Votes Against`),
            `Election Night Votes for Candidate` = sum(`Election Night Votes for Candidate`),
            `Election Night Votes Against` = sum(`Election Night Votes Against`),
            `Mail-In Ballot 1 Votes for Candidate` = sum(`Mail-In Ballot 1 Votes for Candidate`),
            `Mail-In Ballot 1 Votes Against` = sum(`Mail-In Ballot 1 Votes Against`),
            `Provisional Votes for Candidate` = sum(`Provisional Votes for Candidate`),
            `Provisional Votes Against` = sum(`Provisional Votes Against`),
            `Mail-In Ballot 2 Votes for Candidate` = sum(`Mail-In Ballot 2 Votes for Candidate`),
            `Mail-In Ballot 2 Votes Against` = sum(`Mail-In Ballot 2 Votes Against`),
            `Total Votes For Candidate` = sum(`Total Votes For Candidate`),
            `Total Votes Against` = sum(`Total Votes Against`),
            `Total Votes Cast` = sum(`Total Votes Cast`),
            .by = c(County,
                    `County Name`,
                    Legislative,
                    `Office Name`,
                    `Candidate Name`,
                    Party,
                    Winner,
                    `Write-In?`))

# to do: select elections of interest (Judge of the Orphan’s Court, Sherriff, Board of Education At Large, Register of Wills)


# save the resulting data table(s)
# note: may need to create this folder first
write_csv(all_legislative_district_results, file = paste0(dir, "data/final/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))
