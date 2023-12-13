library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

##### Download 2020 precinct population counts corrected for prison gerrymandering (a PDF)

## Uncomment this line if data isn't downloaded yet

# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"))


##### Read population data, as a table from a PDF

## Select Table 3 (adjusted adult population, a.k.a. adjusted voting-age population)

# to help parsing, get dimensions of Table 3 (pages 88-92)
# page_dims_table3 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"),
#                                   pages = 88:92)
# page_dims_table3
# [[1]]
# [1] 1466.67 1133.33
# 
# [[2]]
# [1] 1466.67 1133.33
# 
# [[3]]
# [1] 1466.67 1133.33
# 
# [[4]]
# [1] 1466.67 1133.33
# 
# [[5]]
# [1] 1466.67 1133.33

# parse Table 3
# eyeball "area" from PDF and page dimensions; 188 is approximately 1133.33/6
table3 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"),
                         pages = 88:92,
                         area = list(c(188, 1, 1030, 1466)), # c(top, left, bottom, right)
                         guess = F)

# clean the parsed data
table3 <- table3 %>%
  lapply(as_tibble) %>%
  bind_rows() %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = V3)) %>%
  select(-c(V1, V3)) # remove Congressional District, and V3 is unnecessary now

colnames(table3) <- c("Legislative", "Precinct", "Adjusted_or_Unadjusted", "Census_Total_Pop", "Adjusted_Total_Pop",
                      "Census_Total_Adult_Pop", "Adjusted_Total_Adult_Pop",
                      "Adjusted_One_Race_Adult_Pop", "Adjusted_White_Alone_Adult_Pop", "Adjusted_Black_Alone_Adult_Pop",
                      "Adjusted_American_Indian_Alaskan_Native_Alone_Adult_Pop", "Adjusted_Asian_Alone_Adult_Pop",
                      "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Adult_Pop", "Adjusted_Other_Race_Alone_Adult_Pop",
                      "Adjusted_Multiracial_Adult_Pop", "Adjusted_Hispanic_Latino_Adult_Pop")

table3 <- table3 %>%
  mutate(Legislative = str_remove(string = Legislative, pattern = "240"), # 24 is the Maryland state FIPS code, 0 is padding, so just get the last two digits for [state] legislative district
         Precinct = paste0("0", Precinct)) # zero-pad the precinct name to match the {3 digits}-{3 digits} format in election results data files


##### Save the resulting data tables

write_csv(table3, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_adult_population_2020.csv"))

# Note: voting-age population (VAP), i.e., adult population, i.e., 18+ population, is larger than citizen voting-age population (CVAP), which already overestimates the number of eligible voters (since it doesn't account for disenfranchised citizens)
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)
