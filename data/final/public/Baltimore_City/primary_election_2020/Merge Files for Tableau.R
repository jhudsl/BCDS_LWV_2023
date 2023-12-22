#Read in Leg Dist
legdist<-read.csv("merged_data_legislative_districts_with_precinct.csv", header = TRUE, stringsAsFactors = FALSE)
#Rename columns to reflect leg district
original_cols<-colnames(legdist)
colnames(legdist)<-paste("Leg", "Dist", original_cols, sep="_")

#Read in council file
councildist<-read.csv("merged_data_councilmanic_districts_with_precinct.csv", header=TRUE, stringsAsFactors = FALSE)

#Rename columns to reflect council dist
original_cols2<-colnames(councildist)
colnames(councildist)<-paste("Council", "Dist", original_cols2, sep="_")

#Merge 2 dataframes together
finalmergedatatableau<-merge(legdist, councildist, by.x="Leg_Dist_Precinct", by.y = "Council_Dist_Precinct", all.x=TRUE)

write.csv(finalmergedatatableau, "Leg_and_Council_Data_by_Precinct.csv")