library(tabulizer) # for extract_text() function, for PDFs
library(tidyverse) # for piping (%>%) and various functions

# location of this repository on user's computer
dir <- "../"
raw_data_dir <- paste0(dir, "data/input/public/Baltimore_City/primary_election_2020/")
raw_data_path <- paste0(raw_data_dir, "election_results.pdf")

# if needed, download all 2020 primary election results by city council districts and [state] legislative districts (a PDF)
if (!dir.exists(raw_data_dir)){
  dir.create(raw_data_dir)
}
if (!file.exists(raw_data_path)){
  download.file(url = "https://boe.baltimorecity.gov/sites/default/files/2020-07-29%201257%20-%20PUBLISHED%20-%20PP20%20EL45A%20Election%20Summary%20group%20detail%201.pdf",
                destfile = raw_data_path)
}

# read all election results, as text (creates 1 large character)
# extract_tables() would be hard to use because each page contains multiple tables, we want to pull only some of them, and it's hard to guess where on the page they are
# extract_text() works well for this file because each row in the PDF is in only 1 table (unlike 2022 general election results PDF)
all_results <- extract_text(file = raw_data_path)

# prepare to parse the PDF by dividing it by newlines ("\n") (creates character vector)
results_line_by_line <- unlist(str_split(string = all_results,
                                         pattern = "\n"))

# set elections (offices being voted on) of interest
offices_of_interest <- c("REP Member City Council",
                         "DEM Member City Council")

# function to election result for each councilmanic district
parse_election_results <- function(office){
  
  # get councilmanic districts that voted on this office
  districts <- grep(pattern = office,
                    x = results_line_by_line,
                    value = T) %>%
    str_extract(pattern = "Councilmanic District \\d+") %>%
    str_extract(pattern = "\\d+")
  
  # find which lines in the PDF correspond to the table of election results for this office
  office_indices <- grep(pattern = office,
                         x = results_line_by_line)
  all_total_indices <- grep(pattern = "Total",
                            x = results_line_by_line)
  total_indices <- sapply(office_indices,
                          function(i) (all_total_indices[all_total_indices > i])[1]) # first "total" that appears after the office name
  table_indices <- sapply(1:length(office_indices),
                          function(i) (office_indices[i] + 2):(total_indices[i] - 1))
  
  # read results, from text to data frame
  tables <- table_indices %>%
    lapply(function(i) results_line_by_line[i]) %>%
    lapply(str_split, pattern = "(( {2,})|(\\.  ))+") %>%
    lapply(function(i) lapply(i, function(j) data.frame(Candidate = j[1],
                                                Total_Votes_for_Candidate = j[2],
                                                Total_Votes_for_Candidate_Percent = j[3],
                                                Votes_by_Mail_for_Candidate = j[4],
                                                In_Person_Votes_for_Candidate = j[5],
                                                Provisional_Votes_for_Candidate = j[6])) %>%
             bind_rows)
  
  # combine tables, with district name and name of office being elected
  tables_combined <- 1:length(tables) %>%
    lapply(function(i) tables[[i]] %>% mutate(Councilmanic = districts[i],
                                              Office = office)) %>%
    bind_rows

  return(tables_combined)
}

# parse!
election_results <- lapply(offices_of_interest,
                           parse_election_results) %>%
  bind_rows() %>%
  mutate(Total_Votes_for_Candidate = str_remove(Total_Votes_for_Candidate, pattern = ","), # to help parsing as number later
         Total_Votes_for_Candidate_Percent = str_remove(Total_Votes_for_Candidate_Percent, pattern = ","),
         Votes_by_Mail_for_Candidate = str_remove(Votes_by_Mail_for_Candidate, pattern = ","),
         In_Person_Votes_for_Candidate = str_remove(In_Person_Votes_for_Candidate, pattern = ","),
         Provisional_Votes_for_Candidate = str_remove(Provisional_Votes_for_Candidate, pattern = ","),
         Candidate = str_remove(Candidate, pattern = " ")) %>% # remove initial space
  mutate(Total_Votes_for_Candidate = as.numeric(Total_Votes_for_Candidate),
         Total_Votes_for_Candidate_Percent = as.numeric(Total_Votes_for_Candidate_Percent),
         Votes_by_Mail_for_Candidate = as.numeric(Votes_by_Mail_for_Candidate),
         In_Person_Votes_for_Candidate = as.numeric(In_Person_Votes_for_Candidate),
         Provisional_Votes_for_Candidate = as.numeric(Provisional_Votes_for_Candidate))

# get number of candidates and number of ballots across candidates, for each city council district and party
election_results_aggregated <- election_results %>%
  group_by(Councilmanic, Office) %>%
  summarize(Number_of_Candidates = n(),
            Total_Votes = sum(Total_Votes_for_Candidate),
            Total_Votes_by_Mail = sum(Votes_by_Mail_for_Candidate),
            Total_In_Person_Votes = sum(In_Person_Votes_for_Candidate),
            Total_Provisional_Votes = sum(Provisional_Votes_for_Candidate)) %>%
  mutate(Votes_by_Mail_Percent = round(Total_Votes_by_Mail / Total_Votes * 100, 2),
         In_Person_Votes_Percent = round(Total_In_Person_Votes / Total_Votes * 100, 2),
         Provisional_Votes_Percent = round(Total_Provisional_Votes / Total_Votes * 100, 2))

# pivot wide: candidate names
max_number_of_candidates <- max(election_results_aggregated$Number_of_Candidates)
# > max_number_of_candidates
# [1] 10

election_results_wide <- election_results %>%
  group_by(Councilmanic, Office) %>%
  summarize(Candidate1_Name = Candidate[1],
            Candidate2_Name = ifelse(n() > 1, Candidate[2], NA),
            Candidate3_Name = ifelse(n() > 2, Candidate[3], NA),
            Candidate4_Name = ifelse(n() > 3, Candidate[4], NA),
            Candidate5_Name = ifelse(n() > 4, Candidate[5], NA),
            Candidate6_Name = ifelse(n() > 5, Candidate[6], NA),
            Candidate7_Name = ifelse(n() > 6, Candidate[7], NA),
            Candidate8_Name = ifelse(n() > 7, Candidate[8], NA),
            Candidate9_Name = ifelse(n() > 8, Candidate[9], NA),
            Candidate10_Name = ifelse(n() > 9, Candidate[10], NA),
            Candidate1_TotalVotes = Total_Votes_for_Candidate[1],
            Candidate2_TotalVotes = ifelse(n() > 1, Total_Votes_for_Candidate[2], NA),
            Candidate3_TotalVotes = ifelse(n() > 2, Total_Votes_for_Candidate[3], NA),
            Candidate4_TotalVotes = ifelse(n() > 3, Total_Votes_for_Candidate[4], NA),
            Candidate5_TotalVotes = ifelse(n() > 4, Total_Votes_for_Candidate[5], NA),
            Candidate6_TotalVotes = ifelse(n() > 5, Total_Votes_for_Candidate[6], NA),
            Candidate7_TotalVotes = ifelse(n() > 6, Total_Votes_for_Candidate[7], NA),
            Candidate8_TotalVotes = ifelse(n() > 7, Total_Votes_for_Candidate[8], NA),
            Candidate9_TotalVotes = ifelse(n() > 8, Total_Votes_for_Candidate[9], NA),
            Candidate10_TotalVotes = ifelse(n() > 9, Total_Votes_for_Candidate[10], NA),
            Candidate1_TotalVotesPercent = Total_Votes_for_Candidate_Percent[1],
            Candidate2_TotalVotesPercent = ifelse(n() > 1, Total_Votes_for_Candidate_Percent[2], NA),
            Candidate3_TotalVotesPercent = ifelse(n() > 2, Total_Votes_for_Candidate_Percent[3], NA),
            Candidate4_TotalVotesPercent = ifelse(n() > 3, Total_Votes_for_Candidate_Percent[4], NA),
            Candidate5_TotalVotesPercent = ifelse(n() > 4, Total_Votes_for_Candidate_Percent[5], NA),
            Candidate6_TotalVotesPercent = ifelse(n() > 5, Total_Votes_for_Candidate_Percent[6], NA),
            Candidate7_TotalVotesPercent = ifelse(n() > 6, Total_Votes_for_Candidate_Percent[7], NA),
            Candidate8_TotalVotesPercent = ifelse(n() > 7, Total_Votes_for_Candidate_Percent[8], NA),
            Candidate9_TotalVotesPercent = ifelse(n() > 8, Total_Votes_for_Candidate_Percent[9], NA),
            Candidate10_TotalVotesPercent = ifelse(n() > 9, Total_Votes_for_Candidate_Percent[10], NA),
            Candidate1_VotesByMail = Votes_by_Mail_for_Candidate[1],
            Candidate2_VotesByMail = ifelse(n() > 1, Votes_by_Mail_for_Candidate[2], NA),
            Candidate3_VotesByMail = ifelse(n() > 2, Votes_by_Mail_for_Candidate[3], NA),
            Candidate4_VotesByMail = ifelse(n() > 3, Votes_by_Mail_for_Candidate[4], NA),
            Candidate5_VotesByMail = ifelse(n() > 4, Votes_by_Mail_for_Candidate[5], NA),
            Candidate6_VotesByMail = ifelse(n() > 5, Votes_by_Mail_for_Candidate[6], NA),
            Candidate7_VotesByMail = ifelse(n() > 6, Votes_by_Mail_for_Candidate[7], NA),
            Candidate8_VotesByMail = ifelse(n() > 7, Votes_by_Mail_for_Candidate[8], NA),
            Candidate9_VotesByMail = ifelse(n() > 8, Votes_by_Mail_for_Candidate[9], NA),
            Candidate10_VotesByMail = ifelse(n() > 9, Votes_by_Mail_for_Candidate[10], NA),
            Candidate1_InPersonVotes = In_Person_Votes_for_Candidate[1],
            Candidate2_InPersonVotes = ifelse(n() > 1, In_Person_Votes_for_Candidate[2], NA),
            Candidate3_InPersonVotes = ifelse(n() > 2, In_Person_Votes_for_Candidate[3], NA),
            Candidate4_InPersonVotes = ifelse(n() > 3, In_Person_Votes_for_Candidate[4], NA),
            Candidate5_InPersonVotes = ifelse(n() > 4, In_Person_Votes_for_Candidate[5], NA),
            Candidate6_InPersonVotes = ifelse(n() > 5, In_Person_Votes_for_Candidate[6], NA),
            Candidate7_InPersonVotes = ifelse(n() > 6, In_Person_Votes_for_Candidate[7], NA),
            Candidate8_InPersonVotes = ifelse(n() > 7, In_Person_Votes_for_Candidate[8], NA),
            Candidate9_InPersonVotes = ifelse(n() > 8, In_Person_Votes_for_Candidate[9], NA),
            Candidate10_InPersonVotes = ifelse(n() > 9, In_Person_Votes_for_Candidate[10], NA),
            Candidate1_ProvisionalVotes = Provisional_Votes_for_Candidate[1],
            Candidate2_ProvisionalVotes = ifelse(n() > 1, Provisional_Votes_for_Candidate[2], NA),
            Candidate3_ProvisionalVotes = ifelse(n() > 2, Provisional_Votes_for_Candidate[3], NA),
            Candidate4_ProvisionalVotes = ifelse(n() > 3, Provisional_Votes_for_Candidate[4], NA),
            Candidate5_ProvisionalVotes = ifelse(n() > 4, Provisional_Votes_for_Candidate[5], NA),
            Candidate6_ProvisionalVotes = ifelse(n() > 5, Provisional_Votes_for_Candidate[6], NA),
            Candidate7_ProvisionalVotes = ifelse(n() > 6, Provisional_Votes_for_Candidate[7], NA),
            Candidate8_ProvisionalVotes = ifelse(n() > 7, Provisional_Votes_for_Candidate[8], NA),
            Candidate9_ProvisionalVotes = ifelse(n() > 8, Provisional_Votes_for_Candidate[9], NA),
            Candidate10_ProvisionalVotes = ifelse(n() > 9, Provisional_Votes_for_Candidate[10], NA))

# save the resulting data table(s)
write_csv(election_results, file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_candidate_ballot_type_and_councilmanic_district.csv"))
write_csv(election_results_aggregated, file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_ballot_type_and_councilmanic_district.csv"))
write_csv(election_results_wide, file = paste0(dir, "data/intermediate/public/Baltimore_City/primary_election_2020/results_by_candidate_ballot_type_and_councilmanic_district_wide.csv"))
