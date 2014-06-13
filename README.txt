Assumptions: All requests currently are based on data in the hitting file. Future requests of the system will require data from a pitching file as well. Consider this in the design.

Requirements: When the application is run, use the provided data and calculate the following results and write them to STDOUT. 

1) Most improved batting average( hits / at-­‐bats) from 2009 to 2010. Only include players with at least 200 at-­‐bats. 

2) Slugging percentage for all players on the Oakland A's (teamID = OAK) in 2007. 

3) Who was the AL and NL triple crown winner for 2011 and 2012. If no one won the crown, output "(No winner)"





Description: The application runs three main functions in ParserModule, get_stat_by_team, stat_leader and get_stat_increase_leader.

Each function runs through the csv one time, keeping track of what data it needs as it goes and returning the required data in the form of a hash.

In each function, there is the possibility of sending a complex statistic, like batting average, slugging percentage, stolen base percentage, etc. Each type of allowable complex function is returned as a lambda from StatsModule. The each qualifying row of statistics is passed to this lambda, which returns the statistic and allows further operations. For non-complex statistics, H, AB, SB etc, the stat is either compiled or compared as is.

This keeps the code modular and csv-header-agnostic. This means you can change the headers and use the same functionality for pitchers, and can even be used for other sports or non-sports related numerical processing, assuming the csv contains integers.

All statistical processing is done in StatsModule. Here we keep functions and a few lambdas to compile stats like batting average, that require more than just reading from the CSV.

This app was made using rspec, and all tests are in the /tests folder. The app was version controlled using git. Since I was the only person working on it, I mostly stayed on the main branch.

The only assumption made while using the application was that the csv would be ordered by name, and that they would be in order by year. The order can be ascending or descending. The application covers either case, as long as it is explictly told what the case is. Only Batting-07-12.csv was used Master-small.csv wasn't necessary to fulfill the requirements. 

The application is very flexible, and can return a variety of statistical analysis just based on changing parameters.
Some examples:

a) You could get any stat named in the csv, as well as batting average and slugging for any team in any year by adjusting the parameters.

b) You can search for any stat leader in all of the aforementioned stats, in any year and in either league. Minimums are accounted for, they are currently set at a minimum of 200 AB for slugging and batting average.

c) You can find the largest increase leader in any of the aforementioned stats, in any year, with minimums accounted for.

d) As mentioned above, this can be used for pitchers, different sports, or any stats analysis. Any stat that isn't immediately in the CSV file can have a lambda added to the StatsModule. To add a new stat, stimply add constant for MINIMUMS, STATS, and LAMDA. Then add a case for the name of the stat, which you will then pass to any of the 3 main functions, in constants_and_method_by_stat.