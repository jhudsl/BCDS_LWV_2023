library(data.table)

turnout_table <- fread("data/intermediate/public/baltimore_city_2022_general_election_turnout.csv")

turnout_table[, `Non-Blank Ballots` := `Total Ballots` - `Blank Ballots`][,
  `Turnout Percent` := `Non-Blank Ballots` / Registered * 100]

turnout_table[, `Turnout Percent` := (`Total Ballots` - `Blank Ballots`) / Registered * 100]

hist(turnout_table$`Turnout Percent`,
     main = "Voter turnout across Baltimore City precincts",
     xlab = "Number of non-blank ballots / number of registered voters\n(Median in red)")
abline(v = median(turnout_table$`Turnout Percent`, na.rm = T),
       col = "red", lty = 1)

hist(turnout_table$`Non-Blank Ballots`,
     main = "Number of non-blank ballots across Baltimore City precincts",
     xlab = "(Median in red)")
abline(v = median(turnout_table$`Non-Blank Ballots`, na.rm = T),
       col = "red", lty = 1)

hist(turnout_table$`Blank Ballots`,
     main = "Number of blank ballots across Baltimore City precincts",
     xlab = "(Median in red)")
abline(v = median(turnout_table$`Blank Ballots`, na.rm = T),
       col = "red", lty = 1)

# to do: figure out if mail-in voting is included (hopefully yes and according to residents' address)