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

baltimore_finaldata$PRECINCT<-as.numeric(baltimore_finaldata$PRECINCT)
baltimore_finaldata$GENDER[baltimore_finaldata$GENDER=="F"]<-0
baltimore_finaldata$GENDER[baltimore_finaldata$GENDER=="M"]<-1
baltimore_finaldata$GENDER[baltimore_finaldata$GENDER=="U"]<-NA

##IGNORE CODE
history__by_ward <- baltimore_finaldata %>% 
  group_by(PRECINCT) %>%
  summarize(Gender=length(which(GENDER==0)))

percent<-merge(history__by_ward, history__by_ward1, by="PRECINCT")
percent$percent_female<-percent$Gender/percent$n*100
percent<-percent[,c("PRECINCT", "percent_female")]
####

#Get precinct counts
history__by_ward1 <- baltimore_finaldata %>%
  group_by(PRECINCT) %>%
  count(PRECINCT)

#Get gender counts
history_gender<-baltimore_finaldata %>%
  group_by(PRECINCT) %>%
  count(GENDER)

#Convert to wide form
history_gender_wide <-spread(history_gender, GENDER, n)

#merge gender and total precinct counts
percent1<-merge(history_gender_wide, history__by_ward1, by="PRECINCT")

#calculate percents 
percent1$percent_female<-percent1$`0`/percent1$n*100
percent1$percent_male<-percent1$`1`/percent1$n*100
percent1$percent_unknown<-percent1$`<NA>`/percent1$n*100

#remove all raw count vars to make final dataset
percent1<-percent1[,c("PRECINCT", "percent_female", "percent_male", "percent_unknown")]

#Age
election_year <- 2022
election_date <- as.Date("2022-11-08")
baltimore_finaldata$DOB <- as.Date(baltimore_finaldata$DOB, format = "%m-%d-%Y") ### transform from character to date



baltimore_finaldata <- baltimore_finaldata %>%
  mutate(AGE = floor(as.numeric(difftime(election_date, DOB, units = "days") / 365.25))) ### creates AGE variable; age rounded down
baltimore_age = baltimore_finaldata %>%
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


