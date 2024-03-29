# require modules

require 'csv'
require_relative './lib/ParserModule'
require_relative './lib/StatsModule'

include ParserModule
include StatsModule


FILE_PATH = "Batting-07-12.csv"
CSV_FILE = CSV.read(FILE_PATH, headers:true)
HEADERS = CSV_FILE.headers

years = [2011, 2012]
leagues = ["AL", "NL"]

SLG = "SLG"
TEAM_OAK = "OAK"


# Get Oaklands 2011 team slugging percentage
slg = ParserModule.get_stat_by_team(CSV_FILE, HEADERS, 2007, SLG, TEAM_OAK)
puts "In 2007, OAK has a team slugging percentage of #{slg[0]}"

# Get triple crown winners in each league in 2011, 2012
years.each do |year|
  leagues.each do |league|
    w = ParserModule.offensive_triple_crown_winner_by_year(CSV_FILE, HEADERS, year, league)
    if w.nil?
      puts "#{year} #{league} triple crown: (No Winner)"
    else
      puts "#{year} #{league} triple crown: #{w['name']}"
    end
  end
end

# get the most improved batting average from 2009 to 2010
leader = ParserModule.get_stat_increase_leader(CSV_FILE, HEADERS, 2009, 2010, "BA", false)
puts "The largest leader in batting average change from 2009 to 2010 with at least 200 at bats was #{leader["playerID"]} with an increase of #{leader["difference"].round(3)}"