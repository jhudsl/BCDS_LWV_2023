library(ggplot2)

# location of this repository on user's computer
dir <- "../"

# read data
turnout_2022_table <- read_csv(paste0(dir, "data/intermediate/public/baltimore_city_2022_general_election_turnout_results.csv"))

# reshape table and calculate more variables
turnout_2022_table <- turnout_2022_table %>%
  mutate(Ward = substr(Precinct, start = 1, stop = 3)) %>%
  pivot_wider(names_from = Variable,
              values_from = Count) %>%
  rename(Registered = `REGISTERED VOTERS - TOTAL`,
         `Total Ballots` = `BALLOTS CAST - TOTAL`,
         `Blank Ballots` = `BALLOTS CAST - BLANK`) %>%
  mutate(`Non-Blank Ballots` = `Total Ballots` - `Blank Ballots`,
         `Turnout including Blank Ballots (%)` = `Total Ballots` / Registered * 100,
         `Turnout not including Blank Ballots (%)` = `Non-Blank Ballots` / Registered * 100) # Comment TEST

# aggregate 296 precincts (each contains only 1 polling place) to 28 wards
turnout_2022_table_by_ward <- turnout_2022_table %>%
  group_by(Ward) %>%
  summarize(Registered = sum(Registered),
            `Total Ballots` = sum(`Total Ballots`),
            `Blank Ballots` = sum(`Blank Ballots`),
            `Non-Blank Ballots` = sum(`Non-Blank Ballots`),
            `Turnout including Blank Ballots (%)` = `Total Ballots` / Registered * 100,
            `Turnout not including Blank Ballots (%)` = `Non-Blank Ballots` / Registered * 100)

# aggregate to the city level (Baltimore City is its own county)
turnout_2022_table_by_county <- turnout_2022_table_by_ward %>%
  summarize(Registered = sum(Registered),
            `Total Ballots` = sum(`Total Ballots`),
            `Blank Ballots` = sum(`Blank Ballots`),
            `Non-Blank Ballots` = sum(`Non-Blank Ballots`),
            `Turnout including Blank Ballots (%)` = `Total Ballots` / Registered * 100,
            `Turnout not including Blank Ballots (%)` = `Non-Blank Ballots` / Registered * 100)

# summarize both turnout percentages
turnout_2022_table_by_ward_summary <- turnout_2022_table_by_ward %>%
  select(Ward, `Turnout including Blank Ballots (%)`, `Turnout not including Blank Ballots (%)`) %>%
  pivot_longer(cols = c(`Turnout including Blank Ballots (%)`, `Turnout not including Blank Ballots (%)`),
               names_to = "Metric",
               values_to = "Turnout")

turnout_2022_table_by_county_summary <- turnout_2022_table_by_county %>%
  select(`Turnout including Blank Ballots (%)`, `Turnout not including Blank Ballots (%)`) %>%
  pivot_longer(cols = c(`Turnout including Blank Ballots (%)`, `Turnout not including Blank Ballots (%)`),
               names_to = "Metric",
               values_to = "Turnout")

# to do: figure out if mail-in voting is included (hopefully yes and according to residents' address)

# plot 2022 general election voter turnout
turnout_2022_histogram <- ggplot() +
  geom_histogram(data = turnout_2022_table_by_ward,
                 aes(x = `Turnout including Blank Ballots (%)`),
                 fill = "lightblue",
                 binwidth = 5) +
  geom_vline(data = turnout_2022_table_by_county,
             aes(xintercept = `Turnout including Blank Ballots (%)`),
             color = "red",
             linetype = "dashed") +
  xlab("Number of Ballots / Number of Registered Voters (%)") +
  ylab("Number of Wards") +
  ggtitle("Voter Turnout in 2022 General Election\nacross 28 Baltimore City Wards") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
turnout_2022_histogram

turnout_non_blank_2022_histogram <- ggplot() +
  geom_histogram(data = turnout_2022_table_by_ward,
                 aes(x = `Turnout not including Blank Ballots (%)`),
                 fill = "lightblue",
                 binwidth = 5) +
  geom_vline(data = turnout_2022_table_by_county,
             aes(xintercept = `Turnout not including Blank Ballots (%)`),
             color = "red",
             linetype = "dashed") +
  xlab("Number of Non-Blank Ballots / Number of Registered Voters (%)") +
  ylab("Number of Wards") +
  ggtitle("Voter Turnout in 2022 General Election\nacross 28 Baltimore City Wards") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.grid = element_blank()) +
  theme_bw()
turnout_non_blank_2022_histogram

turnout_both_ballot_types_2022_boxplot <- ggplot() +
  geom_boxplot(data = turnout_2022_table_by_ward_summary,
               aes(y = Turnout)) +
  geom_hline(data = turnout_2022_table_by_county_summary,
             aes(yintercept = Turnout),
             color = "red",
             linetype = "dashed") +
  facet_wrap(vars(Metric), labeller = as_labeller(c(`Turnout including Blank Ballots (%)` = "Including blank ballots",
                                                    `Turnout not including Blank Ballots (%)` = "Not including blank ballots"))) +
  ylab("Voter Turnout (%)") +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid = element_blank()) +
  theme_bw()
turnout_both_ballot_types_2022_boxplot
