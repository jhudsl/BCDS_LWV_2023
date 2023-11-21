library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download 2020 precinct population counts corrected for prison gerrymandering (a PDF)
# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

# read all election results, as text (creates 1 large character)
all_precinct_results <- extract_text(paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

# prepare to parse the PDF by dividing it by newlines ("\n") (creates character vector)
results_line_by_line <- unlist(str_split(string = all_precinct_results,
                                         pattern = "\n"))

# select Table 2 (adjusted total population) and Table 3 (adjusted voting-age population) from the Green report
# note that voting-age population (VAP) is larger than citizen voting-age population (CVAP), thus overestimating the number of eligible voters


