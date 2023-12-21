library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# read in data from data/intermediate/ folder
age_and_sex_of_voted_2020_primary <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/sex_and_age_counts_by_precinct_2020_primary.csv"))
age_of_registered_2020_primary <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_2020-06-02/registered_voters_age.csv"))
sex_of_registered_2020_primary <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_2020-06-02/registered_voters_gender.csv"))
adjusted_adult_population_2020 <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# remove variables that are not of interest
# i.e., remove race but keep Hispanic/Latino to help organizations decide if they need more services in Spanish
# and remove Census population but keep Maryland's adjusted population (adjusted for prison gerrymandering)
# remove Adjusted_or_Unadjusted because the "Adjusted" variables are used or equal to the unadjusted if the state did not adjust
adjusted_adult_population_2020 <- adjusted_adult_population_2020 %>%
  select(-c(Adjusted_or_Unadjusted,
            Census_Total_Pop,
            Census_Total_Adult_Pop,
            Adjusted_One_Race_Adult_Pop,
            Adjusted_White_Alone_Adult_Pop,
            Adjusted_Black_Alone_Adult_Pop,
            Adjusted_American_Indian_Alaskan_Native_Alone_Adult_Pop,
            Adjusted_Asian_Alone_Adult_Pop,
            Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Adult_Pop,
            Adjusted_Other_Race_Alone_Adult_Pop,
            Adjusted_Multiracial_Adult_Pop))

# reformat voter demographic data
# remove 2022 legislative district since we need 2020
age_and_sex_of_voted_2020_primary <- age_and_sex_of_voted_2020_primary %>%
  select(-c(`...1`, LEGISLATIVE_DISTRICTS)) %>% # remove first column, which is row number; remove 2022 legislative district since we need 2020
  rename(Precinct = PRECINCT, Councilmanic = COUNCILMANIC_DISTRICTS,
         Voted_Female = `0`, Voted_Male = `1`, Voted_UnknownSex = `<NA>.x`,
         Voted_16to17 = `16-17`, Voted_18to29 = `18-29`, Voted_30to49 = `30-49`, Voted_50to64 = `50-64`, Voted_65plus = `65+`, Voted_UnknownAge = `<NA>.y`) %>%
  mutate(Precinct = ifelse(nchar(Precinct) == 4, paste0("00", Precinct), paste0("0", Precinct))) %>% # zero-pad the precinct
  mutate(Precinct = paste0(substr(Precinct, 1, 3), "-", substr(Precinct, 4, 6))) %>% # use {3 digit ward}-{3 digit precinct within ward} naming convention for precinct
  mutate(Voted_16to17 = ifelse(is.na(Voted_16to17), 0, Voted_16to17),
         Voted_UnknownAge = ifelse(is.na(Voted_UnknownAge), 0, Voted_UnknownAge),
         Voted_UnknownSex = ifelse(is.na(Voted_UnknownSex), 0, Voted_UnknownSex)) %>%
  mutate(Voted_Total = Voted_16to17 + Voted_18to29 + Voted_30to49 + Voted_50to64 + Voted_65plus + Voted_UnknownAge, # checked: equivalent to Voted_Female + Voted_Male + Voted_UnknownSex
         Voted_Adults = Voted_18to29 + Voted_30to49 + Voted_50to64 + Voted_65plus)

# reformat registered demographic data
# remove 2022 legislative district since we need 2020
age_of_registered_2020_primary <- age_of_registered_2020_primary %>%
  select(-c(LEGISLATIVE_DISTRICTS)) %>% # remove 2022 legislative district since we need 2020
  pivot_wider(names_from = AGE_GROUP, values_from = n) %>%
  rename(Precinct = PRECINCT, Councilmanic = COUNCILMANIC_DISTRICTS,
         Registered_Under16 = `< 16`, Registered_16to17 = `16-17`, Registered_18to29 = `18-29`, Registered_30to49 = `30-49`, Registered_50to64 = `50-64`, Registered_65plus = `65+`, Registered_UnknownAge = `NA`) %>%
  mutate(Precinct = ifelse(nchar(Precinct) == 4, paste0("00", Precinct), paste0("0", Precinct))) %>% # zero-pad the precinct
  mutate(Precinct = paste0(substr(Precinct, 1, 3), "-", substr(Precinct, 4, 6))) %>% # use {3 digit ward}-{3 digit precinct within ward} naming convention for precinct
  mutate(Registered_Under16 = ifelse(is.na(Registered_Under16), 0, Registered_Under16),
         Registered_16to17 = ifelse(is.na(Registered_16to17), 0, Registered_16to17),
         Registered_18to29 = ifelse(is.na(Registered_18to29), 0, Registered_18to29),
         Registered_30to49 = ifelse(is.na(Registered_30to49), 0, Registered_30to49),
         Registered_50to64 = ifelse(is.na(Registered_50to64), 0, Registered_50to64),
         Registered_65plus = ifelse(is.na(Registered_65plus), 0, Registered_65plus),
         Registered_UnknownAge = ifelse(is.na(Registered_UnknownAge), 0, Registered_UnknownAge)) %>%
  mutate(Registered_Total = Registered_Under16 + Registered_16to17 + Registered_18to29 + Registered_30to49 + Registered_50to64 + Registered_65plus + Registered_UnknownAge,
         Registered_Adults = Registered_18to29 + Registered_30to49 + Registered_50to64 + Registered_65plus)

sex_of_registered_2020_primary <- sex_of_registered_2020_primary %>%
  select(-c(LEGISLATIVE_DISTRICTS)) %>% # remove 2022 legislative district since we need 2020
  pivot_wider(names_from = GENDER, values_from = n) %>%
  rename(Precinct = PRECINCT, Councilmanic = COUNCILMANIC_DISTRICTS,
         Registered_Female = `F`, Registered_Male = M, Registered_UnknownSex = U) %>%
  mutate(Precinct = ifelse(nchar(Precinct) == 4, paste0("00", Precinct), paste0("0", Precinct))) %>% # zero-pad the precinct
  mutate(Precinct = paste0(substr(Precinct, 1, 3), "-", substr(Precinct, 4, 6))) %>% # use {3 digit ward}-{3 digit precinct within ward} naming convention for precinct
  mutate(Registered_Female = ifelse(is.na(Registered_Female), 0, Registered_Female),
         Registered_Male = ifelse(is.na(Registered_Male), 0, Registered_Male),
         Registered_UnknownSex = ifelse(is.na(Registered_UnknownSex), 0, Registered_UnknownSex))


# # check which precincts are present in each dataset
# > length(unique(age_and_sex_of_voted_2020_primary$PRECINCT))
# [1] 295
# > length(unique(age_of_registered_2020_primary$Precinct))
# [1] 295
# > length(unique(sex_of_registered_2020_primary$Precinct))
# [1] 295
# > length(unique(adjusted_adult_population_2020$Precinct))
# [1] 299

# precincts_with_no_registered_voters <- unique(adjusted_adult_population_2020$Precinct)[
#   !(unique(adjusted_adult_population_2020$Precinct) %in%
#       unique(sex_of_registered_2020_primary$Precinct))]
# > precincts_with_no_registered_voters
# [1] "012-013" "013-013" "020-012" "021-005" "025-018" ## not sure why there are no voters here

# merge by precinct (which identifies the councilmanic district as well)
# keeping all precincts so that neither total population nor total votes cast get lost when aggregating precincts into districts later
# (so some precincts will have people living there but zero votes cast)
merged_data <- full_join(age_and_sex_of_voted_2020_primary, adjusted_adult_population_2020, by = "Precinct") %>%
  full_join(sex_of_registered_2020_primary) %>%
  full_join(age_of_registered_2020_primary) %>%
  mutate(Precinct = paste0(substr(Precinct, 2, 7))) # use {2 digit ward}-{3 digit precinct within ward} naming convention for precinct

# save merged dataset
write_csv(merged_data, file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/merged_data_by_precinct.csv"))

## odd: in more than 25% of precincts, there are more people registered than recorded as living there by the Green Book (Maryland's adjusted population counts)

# > temp <- precinct_data %>% select(Precinct, Councilmanic, Legislative, Voted_Total, Voted_Adults, Registered_Total, Registered_Adults, Adjusted_Total_Pop, Adjusted_Total_Adult_Pop)
# > summary(temp$Registered_Adults / temp$Adjusted_Total_Adult_Pop)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# 0.05354 1.06652 1.20435 1.23243 1.35814 4.08477       7 
# > summary(temp$Registered_Total / temp$Adjusted_Total_Pop)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# 0.03914 0.85263 0.96983 0.99804 1.11002 3.42474       7
