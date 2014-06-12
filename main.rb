# require modules

require 'csv'
require_relative './lib/ParserModule'
require_relative './lib/StatsModule'

include ParserModule
include StatsModule

file_path = "Batting-07-12.csv"
csv_file = CSV.read(file_path, headers:true)
headers = csv_file.headers
# puts headers.index("AB")
t = ParserModule.get_stat_by_team(csv_file, headers, 2011, "BA","OAK")
# interface notes
# user sets leader is highest, as well as all of above
puts t.to_s

v = ParserModule.stat_leader(csv_file, headers, 2010, "AB", "AL", true)
puts v.to_s
