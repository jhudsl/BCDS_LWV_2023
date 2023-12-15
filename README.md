# Title

**Authors**: Ugochi Ejiogu, Lauren Klein, Michelle Qin, Michael Rosenblum

**Contributors**: League of Women Voters-Baltimore City (especially Nancy Lawler, Billie Roberts Spann, and Flo Valentine), Michael Dunphy, and Sam Novey


**Created**: December 22, 2023

**Overview**: 
In this GitHub, we share code and files related to our project to visualize recent 2022 data regarding voter turnout in Baltimore City. We sought to update this map, originally created by Michael Dunphy and collaborators and currently hosted by the Baltimore Votes Coalition. 

While updating the data, we came across a variety of resources and sources related to the data visualization. This repository is meant to facilitate the ability of others, both within Baltimore and beyond, to visualize similar data related to voter demographics, registration, and turnout at the precinct level. 


## Description of Files

-'code/'
    -'analyze_2022_voter_turnout.R' 
    -'merge_intermediate_datasets.R' 
    -'read_2020_adjusted_adult_population.R'
    -'read_2020_adjusted_total_population.R'
    -'read_2022_general_election_results_from_csv_including_ballot_type.R'
    -'read_2022_general_election_results_from_pdf_including_turnout.R'
    -'read_2022_voter_data.R'
-'data/'
  -'input/
    -'public/'
      -'Baltimore_City/general_election_2022/'
        -'Precinct_results_including_ballot_type.csv'
        -'precinct_results_including_turnout.pdf'
      -'Maryland/'
        -'adjusted_population_data_2020.pdf'
    -'private/'
      -'Maryland/'
        -'Maryland_2022_Registered_Voter List_readme.txt'
        -'Maryland_2022_Registered_Voter_List _.txt'
        -'Maryland_2022_Voting History_Part_1readme.txt'
        -'Maryland_2022_Voting_History'
        -'intermediate/'
        -'public/'
          -'Baltimore_City/'
            -'general_election_2022/'
            -'All_election_results_by_ballot_type.csv'
            -'Gender_by_precinct.csv'
            -'Governor_results.csv'
            -'Turnout_results.csv'
            -'us_senator_results.csv'
            -'Adjusted_adult_population_2020.csv'
            -'Adjusted_total_population_2020.csv'
            -'Baltimore_city_2018_general_election_turnout_results.csv'
            -'merged_data_2022GeneralElection_2020Population.csv'
          -'private/'

## Contact Us

Ugochi Ejiogu; uejiogu1@jh.edu 
Lauren Klein; lklein26@jh.edu
Michelle Qin; mqin8@jh.edu 
Michael Rosenblum; mrosen@jhu.edu 


## Misc (to do: put these somewhere)

Limitations of our estimates: people who aren't U.S. citizens aren't eligible to vote; people convicted of felonies in prison are not eligible to vote either (https://election.lab.ufl.edu/voter-turnout/2022-general-election-turnout/ has the numbers for the state of Maryland) but it's hard to estimate that at the precinct, ward, legislative district level, so we just use Maryland's voting-age population (adjusted for prison gerrymandering) to estimate the population of eligible voters in any precinct in Baltimore City.


When requesting voter registration files, date of births needed to be specifically requested, as these do not come with the data by default. These were important for creating the age variable in the dataset. 

Voter ID duplicates exist in the voting history datafile, mostly for participants who were issued a provisional ballot and  voted in another form or who voted absenteee more than once. 
