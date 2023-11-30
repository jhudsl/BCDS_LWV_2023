library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

### Download 2020 precinct population counts corrected for prison gerrymandering (a PDF)

## Uncomment this line if data isn't downloaded yet

# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

### Read population data, as a table from a PDF

## Select Table 2 (adjusted total population)

# first, get dimensions of page 53 (first page containing table 2)
page_dims_table2 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                                  pages = 53)
# page_dims_table2
# [[1]]
# [1] 1342.37 1037.29


# parse page 53
table2p1 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                           pages = 53,
                           area = list(c(260, 1, 1030, 1342)), # c(top, left, bottom, right); eyeball from PDF and page dimensions; 260 is approx 1037.29/4
                           guess = F)

## to do: use 53:58 instead of 53?

# clean the parsed data
table2p1 <- table2p1[[1]] %>%
  as_tibble %>%
  filter(grepl(pattern = "Baltimore City Precinct", x = V1)) %>%
  select(-c(V1, V7, V16)) # remove blank nonexistent columns
colnames(table2p1) <- c("Precinct", "Adjusted_or_Unadjusted", "Census_Pop", "Adjusted_Total_Pop",
                        "Adjusted_One_Race_Pop", "Adjusted_White_Alone_Pop", "Adjusted_Black_Alone_Pop",
                        "Adjusted_American_Indian_Alaskan_Native_Alone_Pop", "Adjusted_Asian_Alone_Pop",
                        "Adjusted_Native_Hawaiian_Pacific_Islander_Alone_Pop", "Adjusted_Other_Race_Alone_Pop",
                        "Adjusted_Multiracial_Pop", "Adjusted_Hispanic_Latino_Pop", "Adjusted_Total_18Plus_Pop")


# table2p1 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
#                          pages = 53,
#                          columns = list(20), # or list(17)
#                          guess = F)

table2 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                         pages = c(53:58),
                         columns = list(20),
                         guess = F) # set guess = FALSE because we can tell extract_tables() the number of columns


## Select Table 3 (adjusted voting-age population)

table3 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                         pages = 88:92,
                         columns = list(21),
                         guess = F) # set guess = FALSE because we can tell extract_tables() the number of columns

# first, get dimensions of page 88 (first page containing table 3)
page_dims_table3 <- get_page_dims(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                                  pages = 88)
# page_dims_table3
# [[1]]
# [1] 1466.67 1133.33

# parse page 88
table3p1 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                           pages = 88,
                           area = list(c(188, 1, 1030, 1466)), # c(top, left, bottom, right); eyeball from PDF and page dimensions; 188 is approx 1133.33/6
                           guess = F)





# consider using row_split(), col_paste()



# save the resulting data tables
# write_csv(table2, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_precinct_populations_2020.csv"))
# write_csv(table3, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_voting_age_populations_2020.csv"))

# Note: voting-age population (VAP) is larger than citizen voting-age population (CVAP), thus overestimating the number of eligible voters
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)
