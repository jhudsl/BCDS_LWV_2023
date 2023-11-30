library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

##### Download 2020 precinct population counts corrected for prison gerrymandering (a PDF)

## Uncomment this line if data isn't downloaded yet

# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))


##### Read population data, as a table from a PDF

## Select Table 2 (adjusted total population)

# first, get dimensions of Table 2 (pages 53-58)
page_dims_table2 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                                  pages = 53:58)
# page_dims_table2
# [[1]]
# [1] 1342.37 1037.29
# 
# [[2]]
# [1] 1342.37 1037.29
# 
# [[3]]
# [1] 1342.37 1037.29
# 
# [[4]]
# [1] 1342.37 1037.29
# 
# [[5]]
# [1] 1342.37 1037.29
# 
# [[6]]
# [1] 1342.37 1037.29


# parse Table 2
# eyeball "area" from PDF and page dimensions; 260 is approximately 1037.29/4
table2 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                           pages = 53:58,
                           area = list(c(260, 1, 1030, 1342)), # c(top, left, bottom, right)
                           guess = F)

# clean the parsed data
table2 <- table2 %>%
  lapply(as_tibble) %>%
  bind_rows() %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = V1)) %>%
  select(-c(V1, V7, V16)) # remove blank nonexistent columns

colnames(table2) <- c("Precinct", "Adjusted_or_Unadjusted", "Census_Pop", "Adjusted_Total_Pop",
                        "Adjusted_One_Race_Pop", "Adjusted_White_Alone_Pop", "Adjusted_Black_Alone_Pop",
                        "Adjusted_American_Indian_Alaskan_Native_Alone_Pop", "Adjusted_Asian_Alone_Pop",
                        "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Pop", "Adjusted_Other_Race_Alone_Pop",
                        "Adjusted_Multiracial_Pop", "Adjusted_Hispanic_Latino_Pop", "Adjusted_Total_18Plus_Pop")


## Select Table 3 (adjusted voting-age population)

# first, get dimensions of Table 3 (pages 88-92)
page_dims_table3 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                                  pages = 88:92)
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
table3 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                           pages = 88:92,
                           area = list(c(188, 1, 1030, 1466)), # c(top, left, bottom, right)
                           guess = F)

## to do: below this. out of memory Java heap space...

# clean the parsed data
table3 <- table3 %>%
  lapply(as_tibble) %>%
  bind_rows() %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = V1)) %>%
  select(-c(V1, V7, V16)) # remove blank nonexistent columns

colnames(table3) <- c("Precinct", "Adjusted_or_Unadjusted", "Census_Pop", "Adjusted_Total_Pop",
                      "Adjusted_One_Race_Pop", "Adjusted_White_Alone_Pop", "Adjusted_Black_Alone_Pop",
                      "Adjusted_American_Indian_Alaskan_Native_Alone_Pop", "Adjusted_Asian_Alone_Pop",
                      "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Pop", "Adjusted_Other_Race_Alone_Pop",
                      "Adjusted_Multiracial_Pop", "Adjusted_Hispanic_Latino_Pop", "Adjusted_Total_18Plus_Pop")


##### Save the resulting data tables

# write_csv(table2, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_precinct_populations_2020.csv"))
# write_csv(table3, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_voting_age_populations_2020.csv"))

# Note: voting-age population (VAP) is larger than citizen voting-age population (CVAP), thus overestimating the number of eligible voters
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)
