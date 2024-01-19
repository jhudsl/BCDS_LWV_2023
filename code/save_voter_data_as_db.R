### NOTE: This data is not freely available on the internet; user should request the data from https://elections.maryland.gov/pdf/sbeappl.pdf
### NOTE: In this project, we treat this data as PRIVATE because it contains individuals' personal information

library(dplyr)
library(tidyverse) # for piping (%>%) and various functions
library(lubridate) # for working with dates
library(data.table) # for fread()
library(DBI)
library(RSQLite)

# location of this repository on user's computer
dir <- "../"

# setwd("/Users/ugochi/Library/CloudStorage/OneDrive-JohnsHopkins/GitHub/BCDS_LWV_2023/code/")
#-----------------------------------------------------------------------------#

# Read registered voter data
registered_voters <- read.delim(paste0(dir, "data/input/private/Maryland/Maryland_2022_Registered_Voter_List.txt"),
                       na = c("NA",""))

# Read voting history data (.tsv)
voting_history <- readLines(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"))
voting_history <- gsub("\t\t", "\tNA\t", voting_history)
voting_history <- fread(text=voting_history, sep="\t", header=TRUE)

# Transform dates from character to date format
registered_voters <- registered_voters %>%
  mutate(DOB = as.Date(DOB, format = "%m-%d-%Y"),
         STATE_REGISTRATION_DATE = as.Date(STATE_REGISTRATION_DATE, format = "%m-%d-%Y"),
         COUNTY_REGISTRATION_DATE = as.Date(COUNTY_REGISTRATION_DATE, format = "%m-%d-%Y"))
voting_history <- voting_history %>%
  mutate(DOB = as.Date(OB, format = "%m-%d-%Y"))

# Save data as relational database (.db)
connection <- dbConnect(drv = SQLite(),
                        dbname = paste0(dir, "data/input/private/Maryland/Maryland_Dec2023_Voter_Data.db"))
dbWriteTable(connection, "registered_voters", registered_voters)
dbWriteTable(connection, "voting_history", voting_history)
dbDisconnect(connection)
