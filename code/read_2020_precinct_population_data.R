library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download 2020 precinct population counts corrected for prison gerrymandering (a PDF)
# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

# read population data, as a table from a PDF
# select Tables 2 (adjusted total population) and 3 (adjusted voting-age population)

table2p1 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                         pages = 53,
                         columns = list(17),
                         guess = F)

get_page_dims(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

table2 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                         pages = c(53:58),
                         columns = list(20),
                         guess = F) # set guess = FALSE because we can tell extract_tables() the number of columns
table3 <- extract_tables(file = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"),
                         pages = 88:92,
                         columns = list(21),
                         guess = F) # set guess = FALSE because we can tell extract_tables() the number of columns

# consider using row_split(), col_paste()

### ignore below this ###

# read population data, as text from a PDF (creates 1 large character)
all_precinct_results <- extract_text(paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

# prepare to parse the PDF by dividing it by newlines ("\n") (creates character vector)
results_line_by_line <- unlist(str_split(string = all_precinct_results,
                                         pattern = "\n"))

# select Table 2 (adjusted total population) and Table 3 (adjusted voting-age population) from the Green report
# Note: voting-age population (VAP) is larger than citizen voting-age population (CVAP), thus overestimating the number of eligible voters
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)

# number of spaces, not number of columns
ncol_table2 <- 20
ncol_table3 <- 21

# # exploratory
# table2_mentions <- grep(pattern = "Table 2",
#                         x = results_line_by_line)
# table3_mentions <- grep(pattern = "Table 3",
#                         x = results_line_by_line)
# appendixA_mentions <- grep(pattern = "Appendix A",
#                            x = results_line_by_line)

# get boundaries of table 2 and table 3
table2_first_line <- grep(pattern = "Table 2",
                          x = results_line_by_line)[2] # first mention is in the table of contents (TOC), so take second mention
table3_first_line <- grep(pattern = "Table 3",
                          x = results_line_by_line)[2]
appendixA_first_line <- grep(pattern = "Appendix A",
                             x = results_line_by_line)[4] # first mention is in TOC, second mention is in Messenge from the Secretary of Planning, third mention is in "CENSUS DATA and PRODUCTS"; take fourth mention

# get the line numbers of rows of Table 2 and Table 3
baltimore_city_in_tables <- grep(pattern = "Baltimore City Precinct",
                                 x = results_line_by_line)
table2_lines <- baltimore_city_in_tables[(baltimore_city_in_tables >= table2_first_line) & (baltimore_city_in_tables < table3_first_line)]
table3_lines <- baltimore_city_in_tables[(baltimore_city_in_tables >= table3_first_line) & (baltimore_city_in_tables < appendixA_first_line)]

# select the lines in the PDF that correspond to Baltimore City in Tables 2 and 3, respectively
table2 <- results_line_by_line[table2_lines]
table3 <- results_line_by_line[table3_lines]

# parse the text into a data frame
table2 <- str_split_fixed(string = table2,
                          pattern = " ",
                          n = ncol_table2)
table3 <- str_split_fixed(string = table3,
                          pattern = " ",
                          n = ncol_table3)

# to do
# colnames(table2) <- c()
# colnames(table3) <- c()

# drop columns that tell us Baltimore City
# table2 <- as_tibble(table2) %>%
#   select(-c(Baltimore, City, Precinct))
# table3 <- as_tibble(table3)%>%
#   select(-c(Baltimore, City, Precinct))

# save the resulting data tables
# write_csv(table2, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_precinct_populations_2020.csv"))
# write_csv(table3, file = paste0(dir, "data/intermediate/public/Baltimore_City/adjusted_voting_age_populations_2020.csv"))

# Note: voting-age population (VAP) is larger than citizen voting-age population (CVAP), thus overestimating the number of eligible voters
# but this is the best variable we have to estimate eligible voters at the precinct level, since CVAP is calculated by the Census Bureau (not corrected for prison gerrymandering and at the census tract level)
