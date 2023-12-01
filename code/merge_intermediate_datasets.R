library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# read in data from data/intermediate/ folder
turnout_results_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/turnout_results.csv"))
all_election_results_by_ballot_type_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/all_election_results_by_ballot_type.csv"))
governor_results_2022general <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/general_election_2022/governor_results.csv"))
adjusted_adult_population_2020 <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))
adjusted_total_population_2020 <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_total_population_2020.csv"))
# to do: read voter data to get gender/sex of registered and turned-out voters

# to do: consider moving the following line into read_2022_general_election_results_from_pdf_including_turnout.R
turnout_results_2022general <- turnout_results_2022general %>%
  pivot_wider(names_from = Variable,
              values_from = Count)

# # check which precincts are present in each dataset
# > length(unique(turnout_results_2022general$Precinct))
# [1] 296
# > length(unique(all_election_results_by_ballot_type_2022general$`Election District - Precinct`))
# [1] 296
# > length(unique(governor_results_2022general$Precinct))
# [1] 296
# > length(unique(adjusted_adult_population_2020$Precinct))
# [1] 272
# > length(unique(adjusted_total_population_2020$Precinct))
# [1] 269

# adult_population_covered <- unique(adjusted_adult_population_2020$Precinct) %in% unique(turnout_results_2022general$Precinct)
# total_population_covered <- unique(adjusted_total_population_2020$Precinct) %in% unique(turnout_results_2022general$Precinct)
# adult_population_not_covered <- unique(adjusted_adult_population_2020$Precinct)[!adult_population_covered]
# total_population_not_covered <- unique(adjusted_total_population_2020$Precinct)[!total_population_covered]
# > adult_population_not_covered
# [1] "012-013" "013-013" "020-012" "021-005" "025-018" ## hmm, this seems to be missing some
# > total_population_not_covered
# [1] "012-013" "013-013" "020-012" "025-018" ## hmm, this seems to be missing some

# merge, keeping all precincts even if population data are missing
merged_data <- full_join(turnout_results_2022general, adjusted_adult_population_2020, by = "Precinct") %>%
  full_join(adjusted_total_population_2020, by = c("Precinct",
                                                   "Adjusted_or_Unadjusted",
                                                   "Census_Total_Pop",
                                                   "Adjusted_Total_Pop",
                                                   "Adjusted_Total_Adult_Pop"))

# investigate odd situation where some precincts have more people registered or more ballots cast than the adult population
# > summary(merged_data$Adjusted_Total_Adult_Pop - merged_data$`REGISTERED VOTERS - TOTAL`)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# -1315.0    42.5   181.0   280.5   410.0  2860.0      60 
# > summary(merged_data$Census_Total_Adult_Pop - merged_data$`REGISTERED VOTERS - TOTAL`)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# -1319.0    20.0   153.0   267.4   371.5  2858.0      60 
# > summary(merged_data$Adjusted_Total_Adult_Pop - merged_data$`BALLOTS CAST - TOTAL`)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  -316.0   602.5  1024.0  1120.5  1524.0  3988.0      60 
# > summary(merged_data$Census_Total_Adult_Pop - merged_data$`BALLOTS CAST - TOTAL`)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# -317     586    1008    1107    1526    3975      60 
