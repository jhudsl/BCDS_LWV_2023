### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(tidyverse) # for piping (%>%) and various functions
library(lubridate) # for working with dates

# location of this repository on user's computer
dir <- "../"

#-----------------------------------------------------------------------------#

# Election Year + Date (for code flexibility)
election_year <- 2022
election_date <- as.Date("2022-11-08")
  
# Import data
voter_file <- read_csv(paste0(dir, "data/input/private/Maryland/Maryland_", election_year, "_Registered_Voter_List.csv"),
                       na = c("NA",""))
  # Count NAs
  sapply(voter_file, function(x) sum(is.na(x)))

#-----------------------------------------------------------------------------#
### Working with DOB to create AGE feature ###

voter_file$DOB <- as.Date(voter_file$DOB, format = "%m/%d/%y") ### transform from character to date

year(voter_file$DOB) <- ifelse(year(voter_file$DOB) > election_year, 
                               year(voter_file$DOB) - 100, 
                               year(voter_file$DOB)) ### years > election_year changed to reflect 20th century year

voter_file <- voter_file %>%
  mutate(AGE = floor(as.numeric(difftime(election_date, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down

#-----------------------------------------------------------------------------#  

# Filter to people who voted in 2022 general election, in Baltimore City county
baltimore_voters_2022 = voter_file %>%   ### store under new name  
  filter(COUNTY == "Baltimore City")

# Calculate {# of women} and {# of men} by precinct → this is a smaller aggregated dataset.
sum(is.na(voter_file$GENDER)) ### 0 missing gender data

registered_voters_gender_2022 = baltimore_voters_2022 %>%
  group_by(PRECINCT, GENDER) %>%
  summarize(COUNT=n()) ### summarizing gender by precinct

# Create voter AGE groups
sum(is.na(baltimore_voters_2022$AGE)) ### 8 missing ages in Baltimore

baltimore_voters_2022 = baltimore_voters_2022 %>%
  mutate(AGE_GROUP = case_when(AGE < 16 ~ "< 16",
                               AGE = 16 & AGE < 18 ~ "16-17",
                               AGE >=18 & AGE <25 ~ "18-24",
                               AGE >=25 & AGE <35 ~ "25-34",
                               AGE >=35 & AGE <45 ~ "35-44",
                               AGE >=45 & AGE <55 ~ "45-54",
                               AGE >=55 & AGE <65 ~ "55-64",
                               AGE >=65 ~ "65+")) ### creating age group variable

registered_voters_age_2022 = baltimore_voters_2022 %>%
  group_by(AGE_GROUP) %>%
  summarize(COUNT=n()) ### summarizing age groups


# save the resulting data tables
write_csv(baltimore_voters_2022, file = paste0(dir,"data/input/private/Maryland/baltimore_voters_2022.csv"))
write_csv(registered_voters_gender_2022, file = paste0(dir,"data/intermediate/public/Baltimore_City/registered_voters_gender_2022.csv"))
write_csv(registered_voters_age_2022, file = paste0(dir,"data/intermediate/public/Baltimore_City/registered_voters_age_2022.csv"))
