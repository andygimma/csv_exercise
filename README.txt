Assumptions: All requests currently are based on data in the hitting file. Future requests of the system will require data from a pitching file as well. Consider this in the design.

Requirements: When the application is run, use the provided data and calculate the following results and write them to STDOUT. 

1) Most improved batting average( hits / at-­‐bats) from 2009 to 2010. Only include players with at least 200 at-­‐bats. 

2) Slugging percentage for all players on the Oakland A's (teamID = OAK) in 2007. 

3) Who was the AL and NL triple crown winner for 2011 and 2012. If no one won the crown, output "(No winner)"

Description: The application runs three main functions in ParserModule, get_stat_by_team, stat_leader and get_stat_increase_leader.

Each function runs through the csv one time, keeping track of what data it needs. 

In each function, there is the possibility of sending a complex statistic, like batting average, slugging percentage, stolen base percentage, etc. Each type of allowable complex function is returned as a lambda from StatsModule. The each qualifying row of statistics is passed to this lambda, which returns the statistic and allows further operations. For non-complex statistics, H, AB, SB etc, the stat is either compiled or compared as is.

This keeps the code modular and csv header agnostic (can be used for pitchers as well, and can even be used for other sports or non-sports related numerical processing).

All csv parsing is done in ParserModule, all statistical processing is done in StatsModule.

This app was made using rspec, and all tests are in the /tests folder.



