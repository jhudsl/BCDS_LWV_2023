library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"

# uncomment this line if data isn't downloaded yet; to download all 2022 general election results (from online PDF)
# download.file(url = "https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf",
#               destfile = paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

# read all election results, as text
all_precinct_results <- extract_text(paste0(dir, "data/input/public/Maryland/precinct_population_data_2020.pdf"))

### to do: write more code ###




