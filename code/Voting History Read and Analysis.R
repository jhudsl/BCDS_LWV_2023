install.packages("data.table")
library("data.table")


voter_data<-readLines("Maryland_2022_Voting_History")
voter_data<-gsub("\t\t","\tNA\t",voter_data)
voter_data <- fread(text=voter_data, sep="\t", header=TRUE)
write.csv(data, file="Maryland_2022_Voting_History.csv")

registered_voters<-read.delim("Maryland_2022_Registered_Voter_List _.txt")
finaldata<-merge(voter_data, registered_voters, by.x = "Voter ID", by.y = "VTRID")
sum(duplicated(finaldata$`Voter ID`))

unique(finaldata$`Election Description`)
#Filter to Baltimore and correct election
baltimore_finaldata<-finaldata %>%   
  filter(COUNTY == "Baltimore City")
baltimore_finaldata<-baltimore_finaldata %>%
  filter(`Election Description` == "2020 PRESIDENTIAL GENERAL ELECTION")

sum(duplicated(baltimore_finaldata$`Voter ID`))


dupes1<-baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`) | duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
dupes<-baltimore_finaldata[duplicated(baltimore_finaldata$`Voter ID`, fromLast = TRUE), ]
dupes$duplicate<-1
dupes<-dupes[,c("Voter ID", "duplicate")]
nondupe<-merge(baltimore_finaldata, dupes, all.x=TRUE)
nondupe$exclude<-ifelse(nondupe$duplicate==1 & nondupe$Voting_Method=="PROVISIONAL", 1,0)
check<-nondupe[,c("Voting_Method", "duplicate", "exclude")]

baltimoredatadupes1<-subset(nondupe, exclude!=1)
sum(duplicated(baltimoredatadupes1$`Voter ID`))
dupes2<-baltimoredatadupes1[duplicated(baltimoredatadupes1$`Voter ID`) | duplicated(baltimoredatadupes1$`Voter ID`, fromLast = TRUE), ]
finalbaltimoredata<-baltimoredatadupes1 %>% distinct(`Voter ID`, .keep_all = TRUE)
sum(duplicated(finalbaltimoredata$`Voter ID`))


#2020 PRESIDENTIAL GENERAL ELECTION and 2022 GUBERNATORIAL GENERAL ELECTION are options

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
  group_by(PRECINCT) %>%
  count(GENDER)

#Convert to wide form
history_gender_wide <-spread(history_gender, GENDER, n)

#remove all raw count vars to make final dataset

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
#Breakdown age

#By PRECINCT
history_age<-baltimore_age %>%
  group_by(PRECINCT) %>%
  count(AGE_GROUP)
#Convert long to wide format
history_age_wide <-spread(history_age, AGE_GROUP, n)

#join to gender data 
finalhistorybreakdowndata<-merge(history_gender_wide, history_age_wide)

