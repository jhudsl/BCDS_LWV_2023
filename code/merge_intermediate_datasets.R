library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# read in data from data/intermediate/ folder
turnout_results_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/turnout_results.csv"))
ballot_types_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/turnout_by_ballot_type.csv"))
candidate_results_by_ballot_type_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/candidate_results_by_ballot_type.csv"))
adjusted_adult_population_2020 <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))
# to do: read voter data to get gender/sex of registered and turned-out voters

# pivot long data frame(s) to wide
turnout_results_2022general <- turnout_results_2022general %>%
  pivot_wider(names_from = Variable,
              values_from = Count)

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

# # check which precincts are present in each dataset
# > length(unique(turnout_results_2022general$Precinct))
# [1] 296
# > length(unique(ballot_types_2022general$Precinct))
# [1] 296
# > length(unique(candidate_results_by_ballot_type_2022general$Precinct))
# [1] 296
# > length(unique(adjusted_adult_population_2020$Precinct))
# [1] 272

# adult_population_covered <- unique(adjusted_adult_population_2020$Precinct) %in% unique(turnout_results_2022general$Precinct)
# adult_population_not_covered <- unique(adjusted_adult_population_2020$Precinct)[!adult_population_covered]
# > adult_population_not_covered
# [1] "012-013" "013-013" "020-012" "021-005" "025-018" ## hmm, this seems to be missing some

# merge, keeping all precincts even if population data are missing
merged_data <- left_join(turnout_results_2022general, adjusted_adult_population_2020, by = "Precinct") %>%
  full_join(ballot_types_2022general, by = c("Precinct"))

# save merged dataset
write_csv(merged_data, file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/merged_data_precincts.csv"))
