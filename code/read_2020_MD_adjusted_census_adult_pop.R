library(readxl)
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# location of raw data
raw_data_dir <- paste0(dir, "data/input/public/Maryland/")
raw_data_path <- paste0(raw_data_dir, "Table3_Adj.xlsx")

# read in data
col_names_table3 <- c("Congressional", "Legislative", "County_Precinct", "Precinct", "Adjusted_or_Unadjusted", "Census_Total_Pop", "Adjusted_Total_Pop",
                      "Census_Total_Adult_Pop", "Adjusted_Total_Adult_Pop",
                      "Adjusted_One_Race_Adult_Pop", "Adjusted_White_Alone_Adult_Pop", "Adjusted_Black_Alone_Adult_Pop",
                      "Adjusted_American_Indian_Alaskan_Native_Alone_Adult_Pop", "Adjusted_Asian_Alone_Adult_Pop",
                      "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Adult_Pop", "Adjusted_Other_Race_Alone_Adult_Pop",
                      "Adjusted_Multiracial_Adult_Pop", "Adjusted_Hispanic_Latino_Adult_Pop")
table3 <- read_xlsx(raw_data_path, range = "A17:R2096", col_names = col_names_table3)

# filter to Baltimore City precincts
table3 <- table3 %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = County_Precinct)) %>%
  select(-c(Congressional, County_Precinct))

# reformat certain columns (district names)
table3 <- table3 %>%
  mutate(Legislative = str_remove(string = Legislative, pattern = "240"), # 24 is the Maryland state FIPS code, 0 is padding, so just get the last two digits for [state] legislative district
         Precinct = paste0("0", Precinct)) # zero-pad the precinct name to match the {3 digits}-{3 digits} format in election results data files


##### Save the resulting data table(s)

write_csv(table3, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# Note: voting-age population (VAP), i.e., adult population, i.e., 18+ population, is larger than citizen voting-age population (CVAP), which already overestimates the number of eligible voters (since it doesn't account for disenfranchised citizens)
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)
