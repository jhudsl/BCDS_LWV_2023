### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# Import data
voter_file <- read.csv(paste0(dir, "data/input/private/Maryland/Rosenblum Registered Voter List_.csv"))

  # Count NAs
  sapply(voter_file, function(x) sum(is.na(x)))

# Filter to people who voted in 2022 general election, in Baltimore City county
baltimore_voters_2022 = voter_file %>%   ### store under new name  
  filter(COUNTY == "Baltimore City")

# Calculate {# of women} and {# of men} by precinct → this is a smaller aggregated dataset.
sum(is.na(voter_file$GENDER))
  # no missing gender data

table(voter_data_2022$GENDER)
  # F - 14,230
  # M - 13,264
  # U - 283 (What do we think 'U' is? Unspecified?)

gender_by_precinct = baltimore_voters_2022 %>%
  group_by(PRECINCT, GENDER) %>%
  summarize(COUNT=n())


# save the resulting data tables
write_csv(baltimore_voters_2022, file = paste0(dir,"data/input/private/Maryland/baltimore_voters_2022.csv"))
write_csv(gender_by_precinct, file = paste0(dir,"data/intermediate/public/Baltimore_City/general_election_2022/gender_by_precinct.csv"))
