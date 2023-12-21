### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(dplyr)
library(tidyverse) # for piping (%>%) and various functions
library(lubridate) # for working with dates

# location of this repository on user's computer
dir <- "../"

# setwd("/Users/ugochi/Library/CloudStorage/OneDrive-JohnsHopkins/GitHub/BCDS_LWV_2023/code/")
#-----------------------------------------------------------------------------#

# Election Date (for code flexibility)
  # 2020 Primary: 2020-06-02
  # 2022 General: 2022-11-08
election_date <- as.Date("2022-11-08")

# Import data
registered_voters <- read.delim(paste0(dir, "data/input/private/Maryland/Maryland_2022_Registered_Voter_List.txt"),
                       na = c("NA",""))

# sapply(registered_voters, function(x) sum(is.na(x))) ### counts NAs in registered_voters
  
# Transform dates from character to date format
registered_voters <- registered_voters %>%
  mutate(DOB = as.Date(DOB, format = "%m-%d-%Y"),
         STATE_REGISTRATION_DATE = as.Date(STATE_REGISTRATION_DATE, format = "%m-%d-%Y"),
         COUNTY_REGISTRATION_DATE = as.Date(COUNTY_REGISTRATION_DATE, format = "%m-%d-%Y"))

# Exclude those registered after election_date
registered_voters <- registered_voters %>%
  filter(STATE_REGISTRATION_DATE <= election_date) ### removing those who registered AFTER election_date

#-----------------------------------------------------------------------------#
### Working with DOB to create AGE feature ###

registered_voters <- registered_voters %>%
  mutate(AGE = floor(as.numeric(difftime(election_date, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down

#-----------------------------------------------------------------------------#  

# Include only people from Baltimore City county
registered_voters_baltimore = registered_voters %>%   ### store under new name  
  filter(COUNTY == "Baltimore City")

# Calculate {# of women} and {# of men} by precinct → this is a smaller aggregated dataset.
sum(is.na(registered_voters$GENDER)) ### 0 missing gender data

registered_voters_baltimore_gender = registered_voters_baltimore %>%
  group_by(PRECINCT, COUNCILMANIC_DISTRICTS, LEGISLATIVE_DISTRICTS) %>%
  count(GENDER) ### summarizing gender by precinct

# Total adults (18+) registered in Baltimore City
total_adults_registered_baltimore <- registered_voters_baltimore %>%
  filter(AGE >= 18) %>%
  group_by(PRECINCT, COUNCILMANIC_DISTRICTS, LEGISLATIVE_DISTRICTS) %>%
  summarize(COUNT = n())

sum(total_adults_registered_baltimore$COUNT) ### 598,119 over 18 y/o registered before 2022 General Election

# Create voter AGE groups
sum(is.na(registered_voters_baltimore$AGE)) ### 699 missing ages in Baltimore

registered_voters_baltimore = registered_voters_baltimore %>%
  mutate(AGE_GROUP = case_when(AGE < 16 ~ "< 16",
                               AGE = 16 & AGE < 18 ~ "16-17",
                               AGE >=18 & AGE <30 ~ "18-29",
                               AGE >=30 & AGE <50 ~ "30-49",
                               AGE >=50 & AGE <65 ~ "50-64",
                               AGE >=65 ~ "65+")) ### creating age group variable

registered_voters_baltimore_age = registered_voters_baltimore %>%
  group_by(PRECINCT, COUNCILMANIC_DISTRICTS, LEGISLATIVE_DISTRICTS) %>%
  count(AGE_GROUP) ### count number of people per age group by precinct, city council district, and leg district

# temp <- registered_voters_baltimore_age %>% filter(AGE_GROUP == "16-17")
# sum(temp$n) ### count ALL registered ages 16-17

# Drop PII from registered_voters_baltimore
registered_voters_baltimore_noPII <- registered_voters_baltimore %>% select(-c(2:6, 9:18, 22:27, 42)) 
  ### All people registered before election_date (without name and address data)

#-----------------------------------------------------------------------------#

# create folders to store data
if (!dir.exists(paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_", election_date))){
  dir.create(paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_", election_date))
}

# save the resulting data tables
write_csv(registered_voters_baltimore, file = paste0(dir,"data/input/private/Baltimore_City/registered_voters_", election_date, ".csv"))
write_csv(registered_voters_baltimore_gender, file = paste0(dir,"data/intermediate/public/Baltimore_City/registered_voters_", election_date, "/registered_voters_gender.csv"))
write_csv(registered_voters_baltimore_age, file = paste0(dir,"data/intermediate/public/Baltimore_City/registered_voters_", election_date, "/registered_voters_age.csv"))
write_csv(total_adults_registered_baltimore, file = paste0(dir,"data/intermediate/public/Baltimore_City/registered_voters_", election_date, "/registered_adults.csv"))

