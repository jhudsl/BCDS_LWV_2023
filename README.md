# Visualizing the 2020 Primary Election in Baltimore City, Maryland

**Created**: December 22, 2023

**Authors**: Ugochi Ejiogu, Lauren Klein, Michelle Qin, Dr. Michael Rosenblum

**Contributors**: League of Women Voters of Baltimore City, especially Nancy Lawler, Dr. Billie Roberts Spann, and Flo Valentine; Michael Dunphy; Sam Novey

**Acknowledgements**: We created this Tableau dashboard and GitHub repository for the fall 2023 [Baltimore Community Data Science](https://jhudatascience.org/Baltimore_Community_Course/) course at the Johns Hopkins Bloomberg School of Public Health. We would like to thank our instructors Dr. Carrie Wright, Dr. Ava Hoffman, and Dr. Michael Rosenblum as well as [SOURCE](https://source.jhu.edu) for their guidance on this project, lessons on critical service learning, and introduction to the League of Women Voters of Baltimore City.


## Overview

In this GitHub repository, we share code and files related to our project visualizing recent voter turnout in the June 2, 2020 primary election in Baltimore City. Our final product is an interactive dashboard hosted by Tableau Desktop at [this link]().

Our project was inspired by the [dashboard created by Michael Dunphy, Dr. Carrie Wright, Wenhui Yang, Eliane Mitchell, and collaborators at the Baltimore Votes Coalition as part of the 2022 Democracy Data Science Hackathon](https://public.tableau.com/app/profile/michael.dunphy8764/viz/BaltimoreVotesCoalitionDemo/Dashboard). The GitHub repository for their dashboard is at [this link](https://github.com/carriewright11/Party_at_the_polls/tree/main).

<!-- Throughout our project, we came across a variety of data sources and information about election results and eligibility in Baltimore City. -->
<!-- We documented our data sources, code, and contributions of our project. -->

Over the course of this project, we learned a lot about:

- voting eligibility in Maryland (as described by [VOTE411](https://www.vote411.org/node/7850) and the [Maryland State Board of Elections](https://www.elections.maryland.gov/voter_registration/17_year_olds.html)),
- the nuances of population counts (e.g., [adjusting for prison gerrymandering and distinguishing between resident counts, adult resident counts, and citizen counts](https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf)), and
- where to find the most updated and easy-to-process data on Baltimore City election results.

We summarize all the data resources we found on [this Google doc](https://docs.google.com/document/d/16UW9zmYuGrCxumN4ZttN8MLPFq9l1TR3RaSkG8wkYIw/edit?usp=sharing). We also summarize the contributions and suggested next steps (e.g., for future students or participants of a future hackathon) of our project on [this Google doc](https://docs.google.com/document/d/1rhsV4hdX9GnvA5EeF_3W6jqMwtIQsst4n437WWvq3-4/edit?usp=sharing).

We hope that our documentation will facilitate the ability of others, both within Baltimore and beyond, to obtain, process, and visualize similar data related to voter demographics, registration, and turnout at the level of election precincts (also known as "census voting districts" or VTDs), councilmanic (i.e., Baltimore City Council) districts, legislative (i.e., Maryland House of Representatives and Maryland Senate) district, and congressional (U.S. House of Representatives) districts.


## Description of Files

`code/`

When running the code, we advise that the user follow the order below.
  
1. `download_public_data.R`: Run this script to download publicly available data from online (we chose to use government sources because we believe they are released the quickest and most reliably after an election), which is most of the data needed for the dashboard.

    The only private dataset we used was the 2022 voter data, which one can request by submitting the form on [this website](https://elections.maryland.gov/voter_registration/data.html) and paying a fee to the Maryland Board of Elections. When requesting voter registration files, date of birth (DOB) needs to be specifically requested, as these do not come with the data by default. We used the DOB variable to calculate voters' age on the election date before aggregating the counts of voters in each precinct (which we make publicly available in our `data/public/` folder).
    
    To Do: Note about the shapefile being precincts, and redistricting.

3. `read_2020_primary_city_council_election_results.R`
4. `read_2020_MD_adjusted_census_adult_pop.R`: Table 3 is adult population, Table 2 is total population
5. `read_registered_voter_data.R`
6. `read_voting_history_data.R`
7. `merge_2020_primary_intermediate_datasets.R`
8. `aggregate_2020_primary_merged_data_from_precinct_to_districts.R`
9. `make_precinct_councilmanic_legislative_district_keys.R`
10. `append_precinct_to_2020_primary_aggregated_merged_data.R`
11. `Merge Files for Tableau.R` (to do: move this from `data/final/` to `code` and update the filepaths in the script
    
The organization below is not updated yet.

`data/`
  - `input/`
    - `public/`
      - `Baltimore_City/general_election_2022/`
        - `Precinct_results_including_ballot_type.csv`
        - `precinct_results_including_turnout.pdf`
      - `Maryland/`
        - `adjusted_population_data_2020.pdf`
    - `private/`
      - `Maryland/`
        - `Maryland_2022_Registered_Voter List_readme.txt`
        - `Maryland_2022_Registered_Voter_List _.txt`
        - `Maryland_2022_Voting History_Part_1readme.txt`
        - `Maryland_2022_Voting_History`
  - `intermediate/`
    - `public/`
      - `Baltimore_City/`
        - `general_election_2022/`
        - `All_election_results_by_ballot_type.csv`
        - `Gender_by_precinct.csv`
        - `Governor_results.csv`
        - `Turnout_results.csv`
        - `us_senator_results.csv`
        - `Adjusted_adult_population_2020.csv`
        - `Adjusted_total_population_2020.csv`
        - `Baltimore_city_2018_general_election_turnout_results.csv`
        - `merged_data_2022GeneralElection_2020Population.csv`
      - `private/`
    - `final/`

## Contact Us

Ugochi Ejiogu (uejiogu1 [at] jh [dot] edu), Lauren Klein (lklein26 [at] jh [dot] edu), Michelle Qin (mqin8 [at] jh [dot] edu), Michael Rosenblum (mrosen [at] jhu [dot] edu)


## Miscellaneous Notes

**Limitations of Our Estimates**

- People who aren't U.S. citizens aren't eligible to vote; people convicted of felonies in prison are not eligible to vote either (https://election.lab.ufl.edu/voter-turnout/2022-general-election-turnout/ has the numbers for the state of Maryland) but it's hard to estimate that at the precinct, ward, legislative district level, so we just use Maryland's voting-age population (adjusted for prison gerrymandering) to estimate the population of eligible voters in any precinct in Baltimore City.

**Data Tips**

- When requesting voter registration files, date of birth (DOB) needed to be specifically requested, as these do not come with the data by default. These were important for creating the age variable in the dataset. 

- Voter ID duplicates exist in the voting history datafile, mostly for participants who were issued a provisional ballot and voted in another form or who voted absenteee more than once. A person's voter ID does not change across elections (i.e., across time).

**Disclaimer**

The contents of this website are solely the opinions of the authors and not of any organization including Johns Hopkins University nor the League of Women Voters. 
