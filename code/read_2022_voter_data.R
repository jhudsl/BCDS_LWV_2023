### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# Import data
voter_file <- read_csv(paste0(dir, "data/input/private/Maryland/Maryland_2022_Registered_Voter_List.csv"),
                       na = c("NA",""))
  # Count NAs
  sapply(voter_file, function(x) sum(is.na(x)))

history_file <- read_table(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"), 
                       col_names = c("Voter ID","Election Date", "Election Description", "ElectionType",
                                     "Political Party", "Election Code", "Voting Method", "Date of Voting",
                                     "Precinct", "Early Voting Location", "Jurisdiction Code", "CountyName"),
                       na = c("NA", ""," "), skip = 1)

# history_file <- read.table(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"), sep="\t",
#                            col.names = c("Voter ID","Election Date", "Election Description", "ElectionType",
#                                          "Political Party", "Election Code", "Voting Method", "Date of Voting",
#                                          "Precinct", "Early Voting Location", "Jurisdiction Code", "CountyName"),
#                            na.strings = c("NA", ""," "), skip = 1)

  

# Filter to people who voted in 2022 general election, in Baltimore City county
baltimore_voters_2022 = voter_file %>%   ### store under new name  
  filter(COUNTY == "Baltimore City")

# Calculate {# of women} and {# of men} by precinct → this is a smaller aggregated dataset.
sum(is.na(voter_file$GENDER)) # Looking for NAs
  # no missing gender data

table(voter_data_2022$GENDER) # Counts of all women and men registered in MD
  # F - 14,230
  # M - 13,264
  # U - 283 (What do we think 'U' is? Unspecified?)

gender_by_precinct = baltimore_voters_2022 %>%
  group_by(PRECINCT, GENDER) %>%
  summarize(COUNT=n())


# save the resulting data tables
write_csv(baltimore_voters_2022, file = paste0(dir,"data/input/private/Maryland/baltimore_voters_2022.csv"))
write_csv(gender_by_precinct, file = paste0(dir,"data/intermediate/public/Baltimore_City/general_election_2022/gender_by_precinct.csv"))
