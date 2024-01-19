library(tidyverse)
library(ggplot2)

# location of this repository on user's computer
dir <- "../"

# Read in data

legislative_district_data_dir <- paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/")
councilmanic_district_data_dir <- paste0(dir, "data/final/public/Baltimore_City/primary_election_2020/ignore_for_now/total_votes_from_election_report_not_voter_file/")

legislative_district_data_path <- paste0(legislative_district_data_dir, "merged_data_legislative_districts.csv")
councilmanic_district_data_path <- paste0(councilmanic_district_data_dir, "merged_data_councilmanic_districts.csv")

legislative_district_data <- read_csv(legislative_district_data_path) %>%
  mutate(Legislative = as.character(Legislative))
councilmanic_district_data <- read_csv(councilmanic_district_data_path)

# Pivot data to long

legislative_data_long <- legislative_district_data %>%
  pivot_longer(cols = 2:ncol(legislative_district_data), names_to = "Variable", values_to = "Value")
councilmanic_data_long <- councilmanic_district_data %>%
  pivot_longer(cols = 2:ncol(councilmanic_district_data), names_to = "Variable", values_to = "Value")


# Plot sex distribution across councilmanic and legislative districts

legislative_voted_sex_plot <- ggplot(legislative_data_long %>%
                                       filter(Variable %in% c("Female_of_Voted", "Male_of_Voted", "UnknownSex_of_Voted")) %>%
                                       mutate(Variable = ifelse(Variable == "Female_of_Voted",
                                                                "Female",
                                                                ifelse(Variable == "Male_of_Voted",
                                                                       "Male",
                                                                       ifelse(Variable == "UnknownSex_of_Voted",
                                                                              "Unknown",
                                                                              Variable))))) +
  geom_bar(aes(x = Legislative, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Sex Breakdown of People Who Voted\nIn 2020 Baltimore City Primary Election",
       x = "Legislative District",
       y = "% of People Who Voted",
       fill = "Sex") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

councilmanic_voted_sex_plot <- ggplot(councilmanic_data_long %>%
                                       filter(Variable %in% c("Female_of_Voted", "Male_of_Voted", "UnknownSex_of_Voted")) %>%
                                       mutate(Variable = ifelse(Variable == "Female_of_Voted",
                                                                "Female",
                                                                ifelse(Variable == "Male_of_Voted",
                                                                       "Male",
                                                                       ifelse(Variable == "UnknownSex_of_Voted",
                                                                              "Unknown",
                                                                              Variable))))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Sex Breakdown of People Who Voted\nIn 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "% of People Who Voted",
       fill = "Sex") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

legislative_registered_sex_plot <- ggplot(legislative_data_long %>%
                                       filter(Variable %in% c("Female_of_Registered", "Male_of_Registered", "UnknownSex_of_Registered")) %>%
                                       mutate(Variable = ifelse(Variable == "Female_of_Registered",
                                                                "Female",
                                                                ifelse(Variable == "Male_of_Registered",
                                                                       "Male",
                                                                       ifelse(Variable == "UnknownSex_of_Registered",
                                                                              "Unknown",
                                                                              Variable))))) +
  geom_bar(aes(x = Legislative, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Sex Breakdown of People Who Registered\nBefore 2020 Baltimore City Primary Election",
       x = "Legislative District",
       y = "% of People Who Registered",
       fill = "Sex") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

councilmanic_registered_sex_plot <- ggplot(councilmanic_data_long %>%
                                             filter(Variable %in% c("Female_of_Registered", "Male_of_Registered", "UnknownSex_of_Registered")) %>%
                                             mutate(Variable = ifelse(Variable == "Female_of_Registered",
                                                                      "Female",
                                                                      ifelse(Variable == "Male_of_Registered",
                                                                             "Male",
                                                                             ifelse(Variable == "UnknownSex_of_Registered",
                                                                                    "Unknown",
                                                                                    Variable))))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Sex Breakdown of People Who Registered\nBefore 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "% of People Who Registered",
       fill = "Sex") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Plot age distribution across councilmanic and legislative districts

legislative_voted_age_plot <- ggplot(legislative_data_long %>%
                                       filter(Variable %in% c("Ages16to17_of_Voted", "Ages18to29_of_Voted", "Ages30to49_of_Voted", "Ages50to64_of_Voted", "Ages65plus_of_Voted", "UnknownAge_of_Voted")) %>%
                                       mutate(Variable = case_when(Variable == "Ages16to17_of_Voted" ~ "16-17",
                                                                   Variable == "Ages18to29_of_Voted" ~ "18-29",
                                                                   Variable == "Ages30to49_of_Voted" ~ "30-49",
                                                                   Variable == "Ages50to64_of_Voted" ~ "50-64",
                                                                   Variable == "Ages65plus_of_Voted" ~ "65+",
                                                                   Variable == "UnknownAge_of_Voted" ~ "Unknown",
                                                                   .default = Variable))) +
  geom_bar(aes(x = Legislative, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Age Breakdown of People Who Voted\nIn 2020 Baltimore City Primary Election",
       x = "Legislative District",
       y = "% of People Who Voted",
       fill = "Age") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

councilmanic_voted_age_plot <- ggplot(councilmanic_data_long %>%
                                        filter(Variable %in% c("Ages16to17_of_Voted", "Ages18to29_of_Voted", "Ages30to49_of_Voted", "Ages50to64_of_Voted", "Ages65plus_of_Voted", "UnknownAge_of_Voted")) %>%
                                        mutate(Variable = case_when(Variable == "Ages16to17_of_Voted" ~ "16-17",
                                                                    Variable == "Ages18to29_of_Voted" ~ "18-29",
                                                                    Variable == "Ages30to49_of_Voted" ~ "30-49",
                                                                    Variable == "Ages50to64_of_Voted" ~ "50-64",
                                                                    Variable == "Ages65plus_of_Voted" ~ "65+",
                                                                    Variable == "UnknownAge_of_Voted" ~ "Unknown",
                                                                    .default = Variable))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Age Breakdown of People Who Voted\nIn 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "% of People Who Voted",
       fill = "Age") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

legislative_registered_age_plot <- ggplot(legislative_data_long %>%
                                            filter(Variable %in% c("Ages16to17_of_Registered", "Ages18to29_of_Registered", "Ages30to49_of_Registered", "Ages50to64_of_Registered", "Ages65plus_of_Registered", "UnknownAge_of_Registered")) %>%
                                            mutate(Variable = case_when(Variable == "Ages16to17_of_Registered" ~ "16-17",
                                                                        Variable == "Ages18to29_of_Registered" ~ "18-29",
                                                                        Variable == "Ages30to49_of_Registered" ~ "30-49",
                                                                        Variable == "Ages50to64_of_Registered" ~ "50-64",
                                                                        Variable == "Ages65plus_of_Registered" ~ "65+",
                                                                        Variable == "UnknownAge_of_Registered" ~ "Unknown",
                                                                        .default = Variable))) +
  geom_bar(aes(x = Legislative, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Age Breakdown of People Who Registered\nBefore 2020 Baltimore City Primary Election",
       x = "Legislative District",
       y = "% of People Who Registered",
       fill = "Age") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

councilmanic_registered_age_plot <- ggplot(councilmanic_data_long %>%
                                             filter(Variable %in% c("Ages16to17_of_Registered", "Ages18to29_of_Registered", "Ages30to49_of_Registered", "Ages50to64_of_Registered", "Ages65plus_of_Registered", "UnknownAge_of_Registered")) %>%
                                             mutate(Variable = case_when(Variable == "Ages16to17_of_Registered" ~ "16-17",
                                                                         Variable == "Ages18to29_of_Registered" ~ "18-29",
                                                                         Variable == "Ages30to49_of_Registered" ~ "30-49",
                                                                         Variable == "Ages50to64_of_Registered" ~ "50-64",
                                                                         Variable == "Ages65plus_of_Registered" ~ "65+",
                                                                         Variable == "UnknownAge_of_Registered" ~ "Unknown",
                                                                         .default = Variable))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Age Breakdown of People Who Registered\nBefore 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "% of People Who Registered",
       fill = "Age") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Plot election results by councilmanic district

councilmanic_ballot_type_plot <- ggplot(councilmanic_data_long %>%
                                             filter(Variable %in% c("Votes_by_Mail_Percent", "In_Person_Votes_Percent", "Provisional_Votes_Percent")) %>%
                                             mutate(Variable = case_when(Variable == "Votes_by_Mail_Percent" ~ "Votes by Mail",
                                                                         Variable == "In_Person_Votes_Percent" ~ "In Person Votes",
                                                                         Variable == "Provisional_Votes_Percent" ~ "Provisional Votes",
                                                                         .default = Variable))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Types of Ballots in 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "% of Ballots",
       fill = "Ballot Type") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

councilmanic_party_candidates_plot <- ggplot(councilmanic_data_long %>%
                                          filter(Variable %in% c("Number_of_Democrat_Candidates", "Number_of_Republican_Candidates")) %>%
                                          mutate(Variable = case_when(Variable == "Number_of_Democrat_Candidates" ~ "Democrat",
                                                                      Variable == "Number_of_Republican_Candidates" ~ "Republican",
                                                                      .default = Variable))) +
  geom_bar(aes(x = Councilmanic, y = Value, fill = Variable),
           stat = "identity", position = "dodge") +
  labs(title = "Number of Democratic and Republican Candidates for City Council\nIn 2020 Baltimore City Primary Election",
       x = "Councilmanic District",
       y = "Number of Candidates\nfor City Council Seat",
       fill = "Party") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(breaks = 0:10)
