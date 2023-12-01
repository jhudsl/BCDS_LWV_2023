library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

##### Download 2020 precinct population counts corrected for prison gerrymandering (a PDF)

## Uncomment this line if data isn't downloaded yet

# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"))


##### Read population data, as a table from a PDF

## Select Table 2 (adjusted total population)

# to help parsing, get dimensions of Table 2 (pages 53-58)
# page_dims_table2 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"),
#                                   pages = 53:58)
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
table2 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/adjusted_population_data_2020.pdf"),
                           pages = 53:58,
                           area = list(c(260, 1, 1030, 1342)), # c(top, left, bottom, right)
                           guess = F)

# clean the parsed data
table2 <- table2 %>%
  lapply(as_tibble) %>%
  bind_rows() %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = V1)) %>%
  select(-c(V1, V7, V16)) # remove blank nonexistent columns

colnames(table2) <- c("Precinct", "Adjusted_or_Unadjusted", "Census_Total_Pop", "Adjusted_Total_Pop",
                      "Adjusted_One_Race_Pop", "Adjusted_White_Alone_Pop", "Adjusted_Black_Alone_Pop",
                      "Adjusted_American_Indian_Alaskan_Native_Alone_Pop", "Adjusted_Asian_Alone_Pop",
                      "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Pop", "Adjusted_Other_Race_Alone_Pop",
                      "Adjusted_Multiracial_Pop", "Adjusted_Hispanic_Latino_Pop", "Adjusted_Total_18Plus_Pop")

# zero-pad the precinct name to match the {3 digits}-{3 digits} format in election results data files
table2 <- table2 %>%
  mutate(Precinct = paste0("0", Precinct))

##### Save the resulting data table

write_csv(table2, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_total_population_2020.csv"))
