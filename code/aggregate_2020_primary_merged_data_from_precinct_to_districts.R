library(tidyverse)

# location of this repository on user's computer
dir <- "../"

# location to save the processed data (at the end of this script)
final_data_dir_legislative_districts <- paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/")
final_data_dir_councilmanic_districts <- paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/")
final_data_path_legislative_districts <- paste0(final_data_dir_legislative_districts, "merged_data_legislative_districts.csv")
final_data_path_councilmanic_districts <- paste0(final_data_dir_councilmanic_districts, "merged_data_councilmanic_districts.csv")

# read in data
precinct_data <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/merged_data_by_precinct.csv"))
city_council_election_results <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_candidate_ballot_type_and_councilmanic_district.csv"))
city_council_election_results_aggregated <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_ballot_type_and_councilmanic_district.csv"))
city_council_election_results_wide <- read_csv(file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_candidate_ballot_type_and_councilmanic_district_wide.csv"))

# aggregate from precinct to [state] legislative district
# to do: Registered_of_Adjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
# to do: Voted_of_Registered = round(Voted_Total / `REGISTERED VOTERS - TOTAL` * 100, 2),
legislative_district_data <- precinct_data %>%
  summarize(Adjusted_Total_Pop = sum(Adjusted_Total_Pop, na.rm = T),
            Adjusted_Total_Adult_Pop = sum(Adjusted_Total_Adult_Pop, na.rm = T),
            Adjusted_Hispanic_Latino_Adult_Pop = sum(Adjusted_Hispanic_Latino_Adult_Pop, na.rm = T),
            Voted_Total = sum(Voted_Total, na.rm = T),
            Voted_Female = sum(Voted_Female, na.rm = T),
            Voted_Male = sum(Voted_Male, na.rm = T),
            Voted_UnknownSex = sum(Voted_UnknownSex, na.rm = T),
            Voted_16to17 = sum(Voted_16to17, na.rm = T),
            Voted_18to29 = sum(Voted_18to29, na.rm = T),
            Voted_30to49 = sum(Voted_30to49, na.rm = T),
            Voted_50to64 = sum(Voted_50to64, na.rm = T),
            Voted_65plus = sum(Voted_65plus, na.rm = T),
            Voted_UnknownAge = sum(Voted_UnknownAge, na.rm = T),
            .by = Legislative) %>%
  drop_na(Legislative) %>%
  mutate(Voted_of_Adjusted_Adults = round(Voted_Total / Adjusted_Total_Adult_Pop * 100, 2),
         Hispanic_Latino_of_Adjusted_Adults = round(Adjusted_Hispanic_Latino_Adult_Pop / Adjusted_Total_Adult_Pop * 100, 2),
         Female_of_Voted = round(Voted_Female / Voted_Total * 100, 2),
         Male_of_Voted = round(Voted_Male / Voted_Total * 100, 2),
         UnknownSex_of_Voted = round(Voted_UnknownSex / Voted_Total * 100, 2),
         Ages16to17_of_Voted = round(Voted_16to17 / Voted_Total * 100, 2),
         Ages18to29_of_Voted = round(Voted_18to29 / Voted_Total * 100, 2),
         Ages30to49_of_Voted = round(Voted_30to49 / Voted_Total * 100, 2),
         Ages50to64_of_Voted = round(Voted_50to64 / Voted_Total * 100, 2),
         Ages65plus_of_Voted = round(Voted_65plus / Voted_Total * 100, 2),
         UnknownAge_of_Voted = round(Voted_UnknownAge / Voted_Total * 100, 2))

# aggregate from precinct to city council = councilmanic district
# to do: Registered_of_Adjusted_Adults = round(`REGISTERED VOTERS - TOTAL` / Adjusted_Total_Adult_Pop * 100, 2),
# to do: Voted_of_Registered = round(Voted_Total / `REGISTERED VOTERS - TOTAL` * 100, 2),
councilmanic_district_data <- precinct_data %>%
  summarize(Adjusted_Total_Pop = sum(Adjusted_Total_Pop, na.rm = T),
            Adjusted_Total_Adult_Pop = sum(Adjusted_Total_Adult_Pop, na.rm = T),
            Adjusted_Hispanic_Latino_Adult_Pop = sum(Adjusted_Hispanic_Latino_Adult_Pop, na.rm = T),
            Voted_Total = sum(Voted_Total, na.rm = T),
            Voted_Female = sum(Voted_Female, na.rm = T),
            Voted_Male = sum(Voted_Male, na.rm = T),
            Voted_UnknownSex = sum(Voted_UnknownSex, na.rm = T),
            Voted_16to17 = sum(Voted_16to17, na.rm = T),
            Voted_18to29 = sum(Voted_18to29, na.rm = T),
            Voted_30to49 = sum(Voted_30to49, na.rm = T),
            Voted_50to64 = sum(Voted_50to64, na.rm = T),
            Voted_65plus = sum(Voted_65plus, na.rm = T),
            Voted_UnknownAge = sum(Voted_UnknownAge, na.rm = T),
            .by = Councilmanic) %>%
  drop_na(Councilmanic) %>%
  mutate(Voted_of_Adjusted_Adults = round(Voted_Total / Adjusted_Total_Adult_Pop * 100, 2),
         Hispanic_Latino_of_Adjusted_Adults = round(Adjusted_Hispanic_Latino_Adult_Pop / Adjusted_Total_Adult_Pop * 100, 2),
         Female_of_Voted = round(Voted_Female / Voted_Total * 100, 2),
         Male_of_Voted = round(Voted_Male / Voted_Total * 100, 2),
         UnknownSex_of_Voted = round(Voted_UnknownSex / Voted_Total * 100, 2),
         Ages16to17_of_Voted = round(Voted_16to17 / Voted_Total * 100, 2),
         Ages18to29_of_Voted = round(Voted_18to29 / Voted_Total * 100, 2),
         Ages30to49_of_Voted = round(Voted_30to49 / Voted_Total * 100, 2),
         Ages50to64_of_Voted = round(Voted_50to64 / Voted_Total * 100, 2),
         Ages65plus_of_Voted = round(Voted_65plus / Voted_Total * 100, 2),
         UnknownAge_of_Voted = round(Voted_UnknownAge / Voted_Total * 100, 2))

# clean city council election results, then merge
city_council_results_combined_parties <- city_council_election_results_aggregated %>%
  group_by(Councilmanic) %>%
  summarize(Total_Votes = sum(Total_Votes),
            Total_Votes_by_Mail = sum(Total_Votes_by_Mail),
            Total_In_Person_Votes = sum(Total_In_Person_Votes),
            Total_Provisional_Votes = sum(Total_Provisional_Votes)) %>%
  mutate(Votes_by_Mail_Percent = round(Total_Votes_by_Mail / Total_Votes * 100, 2),
         In_Person_Votes_Percent = round(Total_In_Person_Votes / Total_Votes * 100, 2),
         Provisional_Votes_Percent = round(Total_Provisional_Votes / Total_Votes * 100, 2)) %>%
  select(Councilmanic, Votes_by_Mail_Percent, In_Person_Votes_Percent, Provisional_Votes_Percent)

city_council_number_of_candidates <- city_council_election_results_aggregated %>%
  select(Councilmanic, Office, Number_of_Candidates) %>%
  pivot_wider(names_from = Office,
              values_from = Number_of_Candidates) %>%
  rename(Number_of_Democrat_Candidates = `DEM Member City Council`,
         Number_of_Republican_Candidates = `REP Member City Council`) %>%
  mutate(Number_of_Republican_Candidates = ifelse(is.na(Number_of_Republican_Candidates), 0, Number_of_Republican_Candidates))

city_council_results <- full_join(city_council_results_combined_parties,
                                  city_council_number_of_candidates,
                                  by = "Councilmanic") %>%
  mutate(Councilmanic = as.character(Councilmanic)) %>%
  mutate(Councilmanic = case_when(nchar(Councilmanic) == 1 ~ paste0("00", Councilmanic),
                                  nchar(Councilmanic) == 2 ~ paste0("0", Councilmanic),
                                  .default = Councilmanic))

councilmanic_district_data <- councilmanic_district_data %>%
  full_join(city_council_results, by = "Councilmanic")

# save aggregated dataset(s)
if (!dir.exists(final_data_dir_legislative_districts)){
  dir.create(final_data_dir_legislative_districts)
}
if (!dir.exists(final_data_dir_councilmanic_districts)){
  dir.create(final_data_dir_councilmanic_districts)
}

write_csv(legislative_district_data, file = final_data_path_legislative_districts)
write_csv(councilmanic_district_data, file = final_data_path_councilmanic_districts)
