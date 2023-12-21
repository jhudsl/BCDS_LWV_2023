library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# read in data from data/intermediate/ folder
voter_demographics_2020primary <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/sex_and_age_counts_by_precinct_2020_primary.csv"))
# voter_genders_2022registered <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/registered_voters_gender_2022.csv"))
# to do: voter_ages_2022registered and rename gender to sex
adjusted_adult_population_2020 <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# to do: maybe get number of registered voters from voter_genders_2020registered or voter_ages_2020registered

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

# clean voter demographic data
voter_demographics_2020primary <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/sex_and_age_counts_by_precinct_2020_primary.csv"))
voter_demographics_2020primary <- voter_demographics_2020primary %>%
  select(-c(`...1`, LEGISLATIVE_DISTRICTS)) %>% # remove first column, which is row number; remove 2022 legislative district since we need 2020
  rename(Precinct = PRECINCT, Councilmanic = COUNCILMANIC_DISTRICTS,
         Voted_Female = `0`, Voted_Male = `1`, Voted_UnknownSex = `<NA>.x`,
         Voted_16to17 = `16-17`, Voted_18to29 = `18-29`, Voted_30to49 = `30-49`, Voted_50to64 = `50-64`, Voted_65plus = `65+`, Voted_UnknownAge = `<NA>.y`) %>%
  mutate(Precinct = ifelse(nchar(Precinct) == 4, paste0("00", Precinct), paste0("0", Precinct))) %>% # zero-pad the precinct
  mutate(Precinct = paste0(substr(Precinct, 1, 3), "-", substr(Precinct, 4, 6))) %>% # use {3 digit ward}-{3 digit precinct within ward} naming convention for precinct
  mutate(Voted_16to17 = ifelse(is.na(Voted_16to17), 0, Voted_16to17),
         Voted_UnknownAge = ifelse(is.na(Voted_UnknownAge), 0, Voted_UnknownAge),
         Voted_UnknownSex = ifelse(is.na(Voted_UnknownSex), 0, Voted_UnknownSex)) %>%
  mutate(Voted_Total = Voted_Female + Voted_Male + Voted_UnknownSex) # checked: equivalent to Voted_16to17 + Voted_18to29 + Voted_30to49 + Voted_50to64 + Voted_65plus + Voted_UnknownAge

# # check which precincts are present in each dataset
# > length(unique(voter_demographics_2020primary$PRECINCT))
# [1] 295
# > length(unique(adjusted_adult_population_2020$Precinct))
# [1] 272

# adult_population_covered <- unique(adjusted_adult_population_2020$Precinct) %in% unique(voter_demographics_2020primary$Precinct)
# adult_population_not_covered <- unique(adjusted_adult_population_2020$Precinct)[!adult_population_covered]
# > adult_population_not_covered
# [1] "012-013" "013-013" "020-012" "021-005" "025-018" ## hmm, are some missing? 295-272 = 23

# merge, keeping all precincts so that neither total population nor total votes cast get lost when aggregating precincts into districts later
# (so some precincts will have people living there but not votes cast)
merged_data <- full_join(voter_demographics_2020primary, adjusted_adult_population_2020, by = "Precinct") %>%
  mutate(Precinct = paste0(substr(Precinct, 2, 7))) # use {2 digit ward}-{3 digit precinct within ward} naming convention for precinct
# to do: merge registered voters

# save merged dataset
write_csv(merged_data, file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/merged_data_by_precinct.csv"))
