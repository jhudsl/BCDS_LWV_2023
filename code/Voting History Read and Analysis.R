install.packages("data.table")
library("data.table")
library("dplyr")
library("tidyr")

voter_data<-readLines("Maryland_2022_Voting_History")
voter_data<-gsub("\t\t","\tNA\t",voter_data)
voter_data <- fread(text=voter_data, sep="\t", header=TRUE)

registered_voters<-read.delim("Maryland_2022_Registered_Voter_List _.txt")
finaldata<-merge(voter_data, registered_voters, by.x = "Voter ID", by.y = "VTRID")

#Age
finaldata$DOB <- as.Date(finaldata$DOB, format = "%m-%d-%Y")
finaldata$`Election Date` <- as.Date(finaldata$`Election Date`, format = "%m/%d/%Y") 
class(finaldata$`Election Date`)
unique(finaldata$`Election Date`)
### transform from character to date

finaldata <- finaldata %>%
  mutate(AGE = floor(as.numeric(difftime(`Election Date`, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down
finaldata <- finaldata %>%
  mutate(AGE_GROUP = case_when(AGE < 16 ~ "< 16",
                               AGE = 16 & AGE < 18 ~ "16-17",
                               AGE >=18 & AGE <25 ~ "18-24",
                               AGE >=25 & AGE <35 ~ "25-34",
                               AGE >=35 & AGE <45 ~ "35-44",
                               AGE >=45 & AGE <55 ~ "45-54",
                               AGE >=55 & AGE <65 ~ "55-64",
                               AGE >=65 ~ "65+")) ### creating age group variable


finaldatacsv <- subset(finaldata, select = -c(FIRSTNAME, LASTNAME, MIDDLENAME, ADDRESS, STREETNAME, DOB, RESIDENTIALZIP5, RESIDENTIALZIP4,MAILINGADDRESS,MAILINGZIP5,MAILINGZIP4))
write.csv(finaldatacsv, file="Maryland_2022_Voting_History_Deidentified.csv")

#Filter to Baltimore and correct election
baltimore_finaldata<-finaldata %>%   
  filter(COUNTY == "Baltimore City")
baltimore_finaldata<-baltimore_finaldata %>%
  filter(`Election Description` == "2022 GUBERNATORIAL GENERAL ELECTION")
unique(baltimore_finaldata$`Election Description`)
##Options are 2022 GUBERNATORIAL GENERAL ELECTION or 2020 PRESIDENTIAL GENERAL ELECTION

sum(duplicated(baltimore_finaldata$`Voter ID`))

##Find all duplicated ID
dupes1<-baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`) | duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
##Pull only single ID for each duplicated ID
dupes<-baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
##Create indicator column for dupe ID
dupes$duplicate<-1
dupes<-dupes[,c("Voter ID", "duplicate")]
##Join duplicate column to full dataset
nondupe<-merge(baltimore_finaldata, dupes, all.x=TRUE)
##Create exclude variable if there is a duplicate value and ballot is marked as provisional
nondupe$exclude<-ifelse(nondupe$duplicate==1 & nondupe$Voting_Method=="PROVISIONAL", 1,0)
check<-nondupe[,c("Voting_Method", "duplicate", "exclude")]
baltimoredatadupes1<-subset(nondupe, exclude!=1)

#Check for dupes in new dataset
sum(duplicated(baltimoredatadupes1$`Voter ID`))
dupes2<-baltimoredatadupes1[duplicated(baltimoredatadupes1$`Voter ID`) | duplicated(baltimoredatadupes1$`Voter ID`, fromLast = TRUE), ]
#Pull only first duplicated value 
finalbaltimoredata<-baltimoredatadupes1 %>% distinct(`Voter ID`, .keep_all = TRUE)

#confirm no dupes
sum(duplicated(finalbaltimoredata$`Voter ID`))

#Recods gender 
finalbaltimoredata$PRECINCT<-as.numeric(finalbaltimoredata$PRECINCT)
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="F"]<-0
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="M"]<-1
finalbaltimoredata$GENDER[finalbaltimoredata$GENDER=="U"]<-NA


#Get precinct counts
history__by_ward1 <- finalbaltimoredata %>%
  group_by(PRECINCT) %>%
  count(PRECINCT)

#Get gender counts
history_gender<-finalbaltimoredata %>%
  group_by(PRECINCT, COUNCILMANIC_DISTRICTS, LEGISLATIVE_DISTRICTS) %>%
  count(GENDER)

#Convert to wide form
history_gender_wide <-spread(history_gender, GENDER, n)

#By PRECINCT
history_age<-finalbaltimoredata %>%
  group_by(PRECINCT, COUNCILMANIC_DISTRICTS, LEGISLATIVE_DISTRICTS) %>%
  count(AGE_GROUP)

#Convert long to wide format
history_age_wide <-spread(history_age, AGE_GROUP, n)

#join gender and age count by precinct data 
finalhistorybreakdowndata<-merge(history_gender_wide, history_age_wide)

write.csv(finalhistorybreakdowndata, file="Sex_and_Age_Counts_by_Precinct_Council_Leg_Baltimore_2022.csv")

###ignore code, since added age above
#Age
election_year <- 2022
election_date <- as.Date("2022-11-08")
finalbaltimoredata$DOB <- as.Date(finalbaltimoredata$DOB, format = "%m-%d-%Y") ### transform from character to date

finalbaltimoredata <- finalbaltimoredata %>%
  mutate(AGE = floor(as.numeric(difftime(election_date, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down
baltimore_age = finalbaltimoredata %>%
  mutate(AGE_GROUP = case_when(AGE < 16 ~ "< 16",
                               AGE = 16 & AGE < 18 ~ "16-17",
                               AGE >=18 & AGE <25 ~ "18-24",
                               AGE >=25 & AGE <35 ~ "25-34",
                               AGE >=35 & AGE <45 ~ "35-44",
                               AGE >=45 & AGE <55 ~ "45-54",
                               AGE >=55 & AGE <65 ~ "55-64",
                               AGE >=65 ~ "65+")) ### creating age group variable

