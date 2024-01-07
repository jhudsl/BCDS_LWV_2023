# Visualizing the 2020 Primary Election in Baltimore City, Maryland

**Created**: December 22, 2023

**Authors**: Ugochi Ejiogu, Lauren Klein, Michelle Qin, Dr. Michael Rosenblum

**Contributors**: League of Women Voters of Baltimore City, especially Nancy Lawler, Dr. Billie Roberts Spann, and Flo Valentine; Michael Dunphy; Sam Novey

**Acknowledgements**: We created this Tableau dashboard and GitHub repository for the fall 2023 [Baltimore Community Data Science](https://jhudatascience.org/Baltimore_Community_Course/) course at the Johns Hopkins Bloomberg School of Public Health. We would like to thank our instructors Dr. Carrie Wright, Dr. Ava Hoffman, and Dr. Michael Rosenblum as well as [SOURCE](https://source.jhu.edu) for their guidance on this project, lessons on critical service learning, and introduction to the League of Women Voters of Baltimore City.


## Overview

In this GitHub repository, we share code and files related to our project visualizing recent voter turnout in the June 2, 2020 primary election in Baltimore City. Our final product is an interactive dashboard hosted by Tableau Desktop at [link TBD](). We hope that our code and compilation of data sources will be helpful for projects analyzing other elections as well.

Our project was inspired by the [dashboard created by Michael Dunphy, Dr. Carrie Wright, Wenhui Yang, Eliane Mitchell, and collaborators at the Baltimore Votes Coalition as part of the 2022 Democracy Data Science Hackathon](https://public.tableau.com/app/profile/michael.dunphy8764/viz/BaltimoreVotesCoalitionDemo/Dashboard). The GitHub repository for their dashboard is at [this link](https://github.com/carriewright11/Party_at_the_polls/tree/main).

Over the course of this project, we learned a lot about:

- voting eligibility in Maryland (as described by [VOTE411](https://www.vote411.org/node/7850) and the [Maryland State Board of Elections](https://www.elections.maryland.gov/voter_registration/17_year_olds.html)),
- the nuances of population counts (e.g., [adjusting for prison gerrymandering and distinguishing between resident counts, adult resident counts, and citizen counts](https://planning.maryland.gov/Redistricting/Documents/2020data/GreenReport.pdf)), and
- where to find the most updated and easy-to-process data on Baltimore City election results.

We summarize all the data resources we found on [this Google doc](https://docs.google.com/document/d/16UW9zmYuGrCxumN4ZttN8MLPFq9l1TR3RaSkG8wkYIw/edit?usp=sharing). We also summarize the contributions and suggested next steps (e.g., for future students or participants of a future hackathon) of our project on [this Google doc](https://docs.google.com/document/d/1rhsV4hdX9GnvA5EeF_3W6jqMwtIQsst4n437WWvq3-4/edit?usp=sharing).

We hope that our documentation will facilitate the ability of others, both within Baltimore and beyond, to obtain, process, and visualize similar data related to voter demographics, registration, and turnout at the level of election precincts (also known as "census voting districts" or VTDs), councilmanic (i.e., Baltimore City Council) districts, legislative (i.e., Maryland House of Representatives and Maryland Senate) district, and congressional (U.S. House of Representatives) districts.


## Description of Files

`code/`

When running the code, we recommend that the user follow the order below.
  
1. `download_public_data.R`: Run this script to download publicly available data from online (we chose to use government sources because we believe they are released the quickest and most reliably after an election), which is most of the data needed for the dashboard.

   The only private dataset we used was the 2022 voter data, which one can request by submitting the form on [this website](https://elections.maryland.gov/voter_registration/data.html) and paying a fee to the Maryland Board of Elections. When requesting voter registration files, date of birth (DOB) needs to be specifically requested, as these do not come with the data by default. We used the DOB variable to calculate voters' age on the election date before aggregating the counts of voters in each precinct (which we make publicly available in our `data/public/` folder).
   
   See [our data resources Google doc](https://docs.google.com/document/d/16UW9zmYuGrCxumN4ZttN8MLPFq9l1TR3RaSkG8wkYIw/edit?usp=sharing) for more information on alternative data sources, the impact of redistricting on time-varying data, and more. Also, see **Miscellaneous Notes** below for more tips on data processing.

2. `make_precinct_councilmanic_legislative_district_keys.R`
3. `read_2020_primary_city_council_election_results.R`
4. `read_2020_MD_adjusted_census_adult_pop.R`: Table 3 is adult population, Table 2 is total population
5. `read_registered_voter_data.R`
6. `read_voting_history_data.R`
7. `merge_2020_primary_intermediate_datasets.R`
8. `aggregate_2020_primary_merged_data_from_precinct_to_districts.R`
9. `append_precinct_to_2020_primary_aggregated_merged_data.R`
10. `Merge Files for Tableau.R`
11. `plot_district_summary_statistics.R`
    
The organization below is not updated yet.

`data/`

   Since election precincts are nested within both councilmanic (i.e., city council) districts and state legislative districts, while councilmanic and legislative districts may not necessarily align, we calculated our statistics and used the shapefiles at the precinct level, before we aggregated to the councilmanic and legislative district level, which are likely of more interest to organizations working on voting.
   
   Maryland's legislative district boundaries (including some in Baltimore City) in 2020 were different from the current (i.e., 2023) boundaries. However, to the best of our knowledge, election precincts and city council districts (also known as councilmanic districts) have not changed from 2020 to 2023.

   See [our data resources Google doc](https://docs.google.com/document/d/16UW9zmYuGrCxumN4ZttN8MLPFq9l1TR3RaSkG8wkYIw/edit?usp=sharing) for more information on alternative data sources, the impact of redistricting on time-varying data, and more.

   Therefore, due to the availability of current precinct shapefiles on the [Census Bureau's website](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html)
   Due to us analyzing a past election, shapefiles are precincts... but more recently election could use other shapefiles.
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

- Our estimates of the number of eligible voters in a given location are approximate. People who aren't U.S. citizens aren't eligible to vote; people convicted of felonies in prison are not eligible to vote either (https://election.lab.ufl.edu/voter-turnout/2022-general-election-turnout/ has the numbers for the state of Maryland). However, it is hard to estimate those numbers at the precinct, city council district, or legislative district level, so we just use Maryland's voting-age population (adjusted for prison gerrymandering) to estimate the population of eligible voters in any precinct in Baltimore City, so we approximate the voting-eligible population as the 18+ population adjusted for prison gerrymandering, which the Maryland state government releases at the election precinct level every 10 years.
- We don't know the margin of error of the estimates given by our data sources.
- The voter registration file lists voters' sex as M, F, or U, which we interpret as voters' sex being classified as male, female, or unknown.

**Data Processing Tips**

Voter registration files:

- When [requesting voter registration files](https://elections.maryland.gov/voter_registration/data.html), the date of birth (DOB) variable needs to be specifically requested, as it does not come with the data by default. We used this variable to create the age variable in the dataset.
- A person's voter ID does not change across years or elections.
- A voter may be listed as having voted more than once in a single election in the voting history datafile, mostly for participants who were issued a provisional ballot and voted in another form or who voted absentee more than once or in more than one way.
- A voter's listed precinct, legislative, councilmanic, and congressional district are for the year in which you requested the data. Therefore, due to possible redistricting across years, if you are analyzing voter turnout from a previous year, we recommend that you use a different data source to map from precinct to the various districts you want to aggregate to.
- Note about under-18 voters: According to https://www.elections.maryland.gov/voter_registration/17_year_olds.html, “A registered 17 year old may vote in the Primary Election, provided the individual will be 18 years old on or before General Election. These 17 year olds are entitled to vote for all partisan contests and for school board contests but not in a special election (Washington County's ballot question) or municipal election (City of Cumberland in Allegany County). This information reflects the [Court of Appeals' order issued on Friday, February 8, 2008](http://mdcourts.gov/opinions/coa/2008/122a07pc.pdf).”

**Disclaimer**

The contents of this website are solely the opinions of the authors and not of any organization including Johns Hopkins University nor the League of Women Voters. 
