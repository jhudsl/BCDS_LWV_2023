# Visualizing the 2020 Primary Election in Baltimore City, Maryland

**Authors**: Ugochi Ejiogu, Lauren Klein, Michelle Qin, Dr. Michael Rosenblum

**Contributors**: League of Women Voters of Baltimore City, especially Nancy Lawler, Dr. Billie Roberts Spann, and Flo Valentine; Michael Dunphy; Sam Novey

**Acknowledgements**: We created this Tableau dashboard and GitHub repository as a part of our project for the fall 2023 course Baltimore Community Data Science at the Johns Hopkins Bloomberg School of Public Health. We would like to thank our instructors Dr. Carrie Wright, Dr. Ava Hoffman, and Dr. Michael Rosenblum as well as [SOURCE](https://source.jhu.edu) for their guidance on this project, lessons on critical service learning, and for introducing us to the League of Women Voters of Baltimore City.

**Created**: December 22, 2023

**Overview**: 
In this GitHub repository, we share code and files related to our project visualizing recent voter turnout in the June 2, 2020 primary election in Baltimore City. Our final product is an interactive dashboard hosted by Tableau Desktop [here]().

Our project was inspired by [this dashboard](https://public.tableau.com/app/profile/michael.dunphy8764/viz/BaltimoreVotesCoalitionDemo/Dashboard) created by Michael Dunphy, Dr. Carrie Wright, and collaborators at the Baltimore Votes Coalition in the 2022 Democracy Data Science Hackathon. The GitHub repository for their dashboard is [here](https://github.com/carriewright11/Party_at_the_polls/tree/main).

While compiling the data needed for our project, we came across a variety of data sources and resources for voting and elections in Baltimore City. This repository is meant to facilitate the ability of others, both within Baltimore and beyond, to obtain, process, and visualize similar data related to voter demographics, registration, and turnout at the election precinct (also known as "census voting district" or VTD), city council district, legislative district (i.e., districts used by the Maryland House of Representatives and Maryland Senate), or congressional district (used by the U.S. House of Representatives) level. 


## Description of Files

-'code/'
    1. `download_public_data.R`: Run this script to download publicly available data from online (we chose to use government sources because we believe they are released the quickest and most reliably after an election), which is most of the data needed for the dashboard.
    The only private dataset we used was the 2022 voter data, which one can request by submitting the form on [this website](https://elections.maryland.gov/voter_registration/data.html) and paying a fee to the Maryland Board of Elections. When requesting voter registration files, date of birth (DOB) needs to be specifically requested, as these do not come with the data by default. We used the DOB variable to calculate voters' age on the election date before aggregating the counts of voters in each precinct (which we make publicly available in our `data/public/` folder).
    Note about the shapefile being precincts, and redistricting.
    2. `read_2020_primary_city_council_election_results.R`
    3. 'read_2020_MD_adjusted_census_adult_pop.R': Table 3 is adult population, Table 2 is total population
    4. `read_registered_voter_data.R`
    5. `read_voting_history_data.R`
    6. 'merge_2020_primary_intermediate_datasets.R' 
    7. `aggregate_2020_primary_merged_data_from_precinct_to_districts.R`
    8. `make_precinct_councilmanic_legislative_district_keys.R`
    9. `append_precinct_to_2020_primary_aggregated_merged_data.R`
    
    Supplementary:
    -'general_election_2022/read_2022_general_election_results_from_csv_including_ballot_type.R'
    -'general_election_2022/read_2022_general_election_results_from_pdf_including_turnout.R'
    -'general_election_2022/read_2022_voter_data.R'

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

Ugochi Ejiogu (uejiogu1 [at] jh [dot] edu), Lauren Klein (lklein26 [at] jh [dot] edu), Michelle Qin (mqin8 [at] jh [dot] edu), Michael Rosenblum (mrosen [at] jhu [dot] edu)


## Miscellaneous Notes

Limitations of our estimates: people who aren't U.S. citizens aren't eligible to vote; people convicted of felonies in prison are not eligible to vote either (https://election.lab.ufl.edu/voter-turnout/2022-general-election-turnout/ has the numbers for the state of Maryland) but it's hard to estimate that at the precinct, ward, legislative district level, so we just use Maryland's voting-age population (adjusted for prison gerrymandering) to estimate the population of eligible voters in any precinct in Baltimore City.

When requesting voter registration files, date of birth (DOB) needed to be specifically requested, as these do not come with the data by default. These were important for creating the age variable in the dataset. 

Voter ID duplicates exist in the voting history datafile, mostly for participants who were issued a provisional ballot and voted in another form or who voted absenteee more than once. A person's voter ID does not change across elections (i.e., across time).
