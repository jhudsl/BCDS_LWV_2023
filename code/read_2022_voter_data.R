### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(tidyverse) # for piping (%>%) and various functions
library(lubridate) # for working with dates

# location of this repository on user's computer
dir <- "../"

#-----------------------------------------------------------------------------#

# Import data
voter_file <- read_csv(paste0(dir, "data/input/private/Maryland/Maryland_2022_Registered_Voter_List.csv"),
                       na = c("NA",""))
  # Count NAs
  sapply(voter_file, function(x) sum(is.na(x)))

# history_file <- read_table(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"), 
#                        col_names = c("Voter ID","Election Date", "Election Description", "ElectionType",
#                                      "Political Party", "Election Code", "Voting Method", "Date of Voting",
#                                      "Precinct", "Early Voting Location", "Jurisdiction Code", "CountyName"),
#                        na = c("NA", ""," "), skip = 1)

# history_file <- read.table(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"), sep="\t",
#                            col.names = c("Voter ID","Election Date", "Election Description", "ElectionType",
#                                          "Political Party", "Election Code", "Voting Method", "Date of Voting",
#                                          "Precinct", "Early Voting Location", "Jurisdiction Code", "CountyName"),
#                            na.strings = c("NA", ""," "), skip = 1)

#-----------------------------------------------------------------------------#
# Working with DOB to get age of voters
# class(voter_file$DOB) ### checking class -- started as "character"

voter_file$DOB <- as.Date(voter_file$DOB, format = "%m/%d/%y") ### transform from character to date
# class(voter_file$DOB) ### checking class -- is now "Date"
year(voter_file$DOB) <- ifelse(year(voter_file$DOB) > 2022, 
                               year(voter_file$DOB) - 100, 
                               year(voter_file$DOB)) ### years > 2022 changed to reflect 20th century year

voter_file <- voter_file %>%
  mutate(AGE = floor(as.numeric(difftime(as.Date("2022-11-08"), DOB, units = "days") / 365.25))) ### create AGE variable

#-----------------------------------------------------------------------------#  

# Filter to people who voted in 2022 general election, in Baltimore City county
baltimore_voters_2022 = voter_file %>%   ### store under new name  
  filter(COUNTY == "Baltimore City")

# Calculate {# of women} and {# of men} by precinct → this is a smaller aggregated dataset.
sum(is.na(voter_file$GENDER)) ### 0 missing gender data

registered_voters_gender_2022 = baltimore_voters_2022 %>%
  group_by(PRECINCT, GENDER) %>%
  summarize(COUNT=n()) ### summarizing gender by precinct

# Voter age groups
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
