library("data.table")
library("dplyr")
library("tidyr")

# location of this repository on user's computer
dir <- "../"

# election to analyze
election <- "2020 PRESIDENTIAL PRIMARY ELECTION"

# read voting history file (.tsv)
voter_data <- readLines(paste0(dir, "data/input/private/Maryland/Maryland_2022_Voting_History"))
voter_data <- gsub("\t\t","\tNA\t",voter_data)
voter_data <- fread(text=voter_data, sep="\t", header=TRUE)

# read voter registration file (.txt); currently registered voters (as of the data being requested in December 2023)
registered_voters <- read.delim(paste0(dir, "data/input/private/Maryland/Maryland_2022_Registered_Voter_List.txt"))
finaldata <- merge(voter_data, registered_voters, by.x = "Voter ID", by.y = "VTRID")

### Calculate age (categorized) on Election Day using DOB

finaldata$DOB <- as.Date(finaldata$DOB, format = "%m-%d-%Y")
finaldata$`Election Date` <- as.Date(finaldata$`Election Date`, format = "%m/%d/%Y") 
# class(finaldata$`Election Date`) # checks that the dates are the Date class
# unique(finaldata$`Election Date`) # checks the unique number of election dates

#Age groups 18-29, 30-49, 50-64, 65+
finaldata <- finaldata %>%
  mutate(AGE = floor(as.numeric(difftime(`Election Date`, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down
finaldata <- finaldata %>%
  mutate(AGE_GROUP = case_when(AGE < 16 ~ "< 16",
                               AGE = 16 & AGE < 18 ~ "16-17",
                               AGE >=18 & AGE <29 ~ "18-29",
                               AGE >=30 & AGE <49 ~ "30-49",
                               AGE >=50 & AGE <64 ~ "50-64",
                               AGE >=65 ~ "65+")) ### creating age group variable

# save csv
finaldatacsv <- subset(finaldata, select = -c(FIRSTNAME, LASTNAME, MIDDLENAME, ADDRESS, STREETNAME, DOB, RESIDENTIALZIP5, RESIDENTIALZIP4,MAILINGADDRESS,MAILINGZIP5,MAILINGZIP4))
write_csv(finaldatacsv, file="Maryland_2022_Voting_History_Deidentified.csv")

### Filter to Baltimore and correct election
baltimore_finaldata <- finaldata %>%   
  filter(COUNTY == "Baltimore City")
baltimore_finaldata <- baltimore_finaldata %>%
  filter(`Election Description` == election)
# unique(baltimore_finaldata$`Election Description`)
# Options are 2022 GUBERNATORIAL GENERAL ELECTION or 2020 PRESIDENTIAL GENERAL ELECTION

# check number of voters who had multiple ballots (some could be provisional)
# sum(duplicated(baltimore_finaldata$`Voter ID`))

### For voters who had multiple ballots recorded in this dataset, remove provisional ballots; for remaining duplicates, save just the first ballot in the dataset

# Find all duplicated ID
dupes1 <- baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`) | duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
# Pull only single ID for each duplicated ID
dupes <- baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
# Create indicator column for dupe ID
dupes$duplicate <- 1
dupes <- dupes[,c("Voter ID", "duplicate")]
# Join duplicate column to full dataset
nondupe <- merge(baltimore_finaldata, dupes, all.x=TRUE)
# Create exclude variable if there is a duplicate value and ballot is marked as provisional
nondupe$exclude <- ifelse(nondupe$duplicate == 1 & nondupe$Voting_Method == "PROVISIONAL", 1,0)
check <- nondupe[,c("Voting_Method", "duplicate", "exclude")]
baltimoredatadupes1 <- subset(nondupe, exclude!=1)

# Check for dupes in new dataset
sum(duplicated(baltimoredatadupes1$`Voter ID`))
dupes2 <- baltimoredatadupes1[duplicated(baltimoredatadupes1$`Voter ID`) | duplicated(baltimoredatadupes1$`Voter ID`, fromLast = TRUE), ]
# Pull only first duplicated value 
finalbaltimoredata <- baltimoredatadupes1 %>% distinct(`Voter ID`, .keep_all = TRUE)

# confirm no dupes
# sum(duplicated(finalbaltimoredata$`Voter ID`))

### Record sex as 0 if woman, 1 if man, NA if unknown
finalbaltimoredata$PRECINCT <- as.numeric(finalbaltimoredata$PRECINCT)
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="F"] <- 0
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="M"] <- 1
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="U"] <- NA


# Get sex counts by precinct
history_sex <- finalbaltimoredata %>%
  group_by(PRECINCT) %>%
  count(GENDER)

# Convert to wide form
history_sex_wide <-spread(history_sex, GENDER, n)

# Get age group counts by precinct
history_age <- finalbaltimoredata %>%
  group_by(PRECINCT) %>%
  count(AGE_GROUP)

# Convert long to wide format
history_age_wide <-spread(history_age, AGE_GROUP, n)

# join sex and age count by precinct data 
sex_and_age_counts_by_precinct <- merge(history_sex_wide, history_age_wide)

# save csv(s)
write.csv(sex_and_age_counts_by_precinct, "sex_and_age_counts_by_precinct_2020_primary.csv")
