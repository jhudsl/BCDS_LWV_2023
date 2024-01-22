# location of this repository on user's computer
dir <- "../"

# urls for the data
data_urls <- list()
data_urls[["adjusted_population_data_2020"]] <- "https://planning.maryland.gov/Redistricting/Documents/2020data/Table3_Adj.xlsx"
data_urls[["baltimore_2020_primary_results"]] <- "https://boe.baltimorecity.gov/sites/default/files/2020-07-29%201257%20-%20PUBLISHED%20-%20PP20%20EL45A%20Election%20Summary%20group%20detail%201.pdf"
data_urls[["precinct_shapefiles_2020"]] <- "https://www2.census.gov/geo/tiger/TIGER2020PL/LAYER/VTD/2020/tl_2020_24_vtd20.zip"

# directories (folders) within the repository for the data to be downloaded
data_dirs <- list()
data_dirs[["adjusted_population_data_2020"]] <- paste0(dir, "data/input/public/Maryland/")
data_dirs[["baltimore_2020_primary_results"]] <- paste0(dir, "data/input/public/Baltimore_City/primary_election_2020/")
data_dirs[["precinct_shapefiles_2020"]] <- paste0(dir, "data/input/public/Maryland/") # alternatively, download from the Redistricting Hub's website (need to make a free account)

# location (filepaths) within the repository for the data to be downloaded
data_paths <- list()
data_paths[["adjusted_population_data_2020"]] <- paste0(data_dirs[["adjusted_population_data_2020"]], "Table3_Adj.xlsx")
data_paths[["baltimore_2020_primary_results"]] <- paste0(data_dirs[["baltimore_2020_primary_results"]], "election_results.pdf")
data_paths[["precinct_shapefiles_2020"]] <- paste0(data_dirs[["precinct_shapefiles_2020"]], "") # the zip file will be downloaded as folder called tl_2020_24_vtd20/

# download the data
for (data_name in names(data_urls)){
  if (!dir.exists(data_dirs[[data_name]])){
    dir.create(data_dirs[[data_name]], recursive = T)
  }
  if (!file.exists(data_paths[[data_name]])){
    download.file(url = data_urls[[data_name]],
                  destfile = data_paths[[data_name]])
  }
}
