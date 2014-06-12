require_relative '../lib/ParserModule'

# handle raising known errors

describe ParserModule do
  include ParserModule
  
  let(:stats_array_batting_average) {["AB", "H"]}
  let(:stats_hash_batting_average) { { "AB" => 0, "H" => 0 } }
  let(:stats_hash_slugging) { { "AB" => 0, "H" => 0, "2B" => 0, "3B" => 0, "HR" => 0 } }
  let(:stat_hits) { "H" }
  let(:stat_batting_average) { "BA" }
  let(:year_2010) { 2010 }
  let(:headers) { ["playerID", "yearID", "league", "teamID", "G", "AB", "R", "H", "2B", "3B", "HR", "RBI", "SB", "CS"] }
  let(:row) { ["name1", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 10, 10, 10] }
  let(:stat_rows) { [["name2", 2011, "AL", "SEA", 100, 500, 100, 100, 10, 10, 10, 10, 10], ["name3", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 10, 10, 10], ["name4", 2010, "NL", "ATL", nil, nil, nil, nil, nil, nil, nil, nil, nil], ["name", 2010, "AL", "OAK", 100, 500, 100, 100, 10, 10, 10, 10, 10], ["name5", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 10, 10, 10]] }

  
  context "if passing create_stats_hash an array as first param" do
    it "should return a hash with array elements as keys, values should be set to 0" do
      stats_hash = ParserModule.create_stats_hash(stats_array_batting_average, stat_hits)
      expect(stats_hash).to eq(stats_hash_batting_average)
    end
  end
  
  context "if passing create_stats_hash a nil array as first param" do
    it "should return a hash with second param as key, value should be set to 0" do
      stats_hash = ParserModule.create_stats_hash(nil, stat_hits)
      expect(stats_hash).to eq({stat_hits => 0})
    end
  end
  
  it "should return the index number in the header array that matches the stat_name" do
#  
    index = ParserModule.headers_index_by_stat_name(headers, stat_hits)
    true_index = headers.index(stat_hits)
    expect(index).to eq(true_index)
  end
  
  it "should test match_year? params for equality" do
    same_year = ParserModule.match_year?(row, headers, 2010)
    expect(same_year).to eq(true)
    
    same_year = ParserModule.match_year?(row, headers, 2011)
    expect(same_year).to eq(false)
  end
  
  it "should test match_team? params for equality" do
    same_team = ParserModule.match_team?(row, headers, "ATL")
    expect(same_team).to eq(true)
    
    same_team = ParserModule.match_team?(row, headers, "SEA")
    expect(same_team).to eq(false)
  end
  
  it "should return the correct value in a given row, with headers and stat_name provided from value_by_row" do
    value = ParserModule.value_by_row(row, headers, stat_hits)
    expect(value).to eq(100)
  end
  
  it "should return a hash of stat names for keys and rows for values from compile_stat_by_row" do
    updated_stats_hash = ParserModule.compile_stat_by_row(row, headers, nil, stats_hash_batting_average)
    expect(updated_stats_hash).to eq({"AB"=>500, "H"=>100})
    
    updated_stats_hash = ParserModule.compile_stat_by_row(row, headers, nil, stats_hash_slugging)
    expect(updated_stats_hash).to eq({"AB"=>500, "H"=>100, "2B" => 10, "3B" => 10, "HR" => 10})
  end
  
  context "given a single stat value" do
    it "should add up all instances of that stat, and return the sum in a stats_hash" do
      stats_hash, team_name, year = ParserModule.get_stat_by_team(stat_rows, headers, year_2010, stat_hits, "ATL")
      expect(stats_hash).to eq({"H"=>200})
      expect(team_name).to eq("ATL")
      expect(year).to eq(year_2010)
    end
  end
  
  context "given a complex stat value (like batting average)" do
    it "should add up all of the values needed for that stat, and return a hash with multiple elements" do
      stats_hash, team_name, year = ParserModule.get_stat_by_team(stat_rows, headers, year_2010, stat_batting_average, "ATL")
      # only testing to make sure it returns a value. This stat is provided by code in StatsModule and will be tested there
      expect(stats_hash.nil?).to eq(false)
      expect(team_name).to eq("ATL")
      expect(year).to eq(year_2010)
    end
  end

end