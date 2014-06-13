require_relative '../lib/ParserModule'

# handle raising known errors

describe ParserModule do
  include ParserModule
  
  let(:stats_array_batting_average) {["AB", "H"]}
  let(:stats_hash_batting_average) { { "AB" => 0, "H" => 0 } }
  let(:stats_hash_hits) { { "H" => 0 } }
  let(:stats_hash_slugging) { { "AB" => 0, "H" => 0, "2B" => 0, "3B" => 0, "HR" => 0 } }
  let(:stat_hits) { "H" }
  let(:stat_batting_average) { "BA" }
  let(:year_2010) { 2010 }
  let(:leader_is_highest_true) { true }
  let(:leader_is_highest_false) { false }
  let(:minimums_hash) { { "AB" => 400 } }
  let(:minimums_hash_nil) { nil }
  let(:stats_hash_above_minimum) { {"AB" => 500, "H" => 100} }
  let(:stats_hash_below_minimum) { {"AB" => 300, "H" => 100} }
  let(:leader_hash_hits) { { "H" => 200 } }
  let(:challenger_hash_hits_low) { { "H" => 100 } }
  let(:challenger_hash_hits_high) { { "H" => 300 } }
  let(:headers) { ["playerID", "yearID", "league", "teamID", "G", "AB", "R", "H", "2B", "3B", "HR", "RBI", "SB", "CS"] }
  let(:row) { ["name1", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 10, 10, 10] }
  let(:stat_rows) { [["name2", 2011, "AL", "SEA", 100, 500, 100, 100, 10, 10, 10, 10, 10, 0], ["name3", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 5, 10, 10, 0], ["name4", 2010, "NL", "ATL", 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], ["name", 2010, "AL", "OAK", 100, 500, 100, 100, 10, 10, 10, 10, 10, 0], ["name5", 2010, "NL", "ATL", 100, 500, 100, 100, 10, 10, 10, 10, 10, 0]] }

  
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
    updated_stats_hash = ParserModule.compile_stat_by_row(row, headers, stats_hash_batting_average)
    expect(updated_stats_hash).to eq({"AB"=>500, "H"=>100})
    
    updated_stats_hash = ParserModule.compile_stat_by_row(row, headers, stats_hash_slugging)
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
  
  context "if stats_hash doesn't meet the minimum requirements in meets_minimums?" do
    it "should return false" do
      meets_minimums = ParserModule.meets_minimums?(stats_hash_below_minimum, minimums_hash)
      expect(meets_minimums).to eq(false)
    end
  end
  
  context "if stats_hash meets the minimum requirements in meets_minimums?" do
    it "should return true" do
      meets_minimums = ParserModule.meets_minimums?(stats_hash_above_minimum, minimums_hash)
      expect(meets_minimums).to eq(true)
    end
  end
  
  context "if the league param matches the league in row in match_league?" do
    it "should return true" do
      meets_minimums = ParserModule.match_league?(row, headers, "NL")
      expect(meets_minimums).to eq(true)
    end
  end
  
  context "if the league param doesn't match the league in row in match_league?" do
    it "should return false" do
      meets_minimums = ParserModule.match_league?(row, headers, "AL")
      expect(meets_minimums).to eq(false)
    end
  end
  
  it "should return the value of the stat and player name in a given row, with return_stat_by_row" do
    stat = ParserModule.return_stat_by_row(row, headers, stats_hash_hits)
    expect(stat).to eq({"H"=>100, "name"=>"name1"})
  end

  it "should return the stat leader of a given stat using stat_leader" do
    leader = ParserModule.stat_leader(stat_rows, headers, year_2010, stat_hits, "AL", leader_is_highest_true)
    expect(leader).to eq({"H"=>100, "name"=>"name"})
  end
  
  context "when using challenger_beats_leader()" do
    context "if complex_stat is nil in challenger_beats_leader()" do
      it "should compare the leader and challenger hashes, and return the player with the highest total" do
	leader_hash = ParserModule.challenger_beats_leader(challenger_hash_hits_high, leader_hash, minimums_hash_nil, stat_hits, StatsModule.return_miscellaneous_stats_lambda, leader_is_highest_true, nil)
	expect(leader_hash).to eq(challenger_hash_hits_high)
      end
    end
    
    context "if complex_stat is not nil and leader_hash is nil in challenger_beats_leader()" do
      it "should return challenger_hash" do
	leader_hash = ParserModule.challenger_beats_leader(challenger_hash_hits_high, nil, minimums_hash_nil, stat_hits, StatsModule.return_miscellaneous_stats_lambda, leader_is_highest_true, nil)
	expect(leader_hash).to eq(challenger_hash_hits_high)
      end
    end
    
    context "if complex_stat is not nil and all params and flags are met in challenger_beats_leader()" do
      it "should return correct hash" do
	leader_hash = ParserModule.challenger_beats_leader(challenger_hash_hits_high, leader_hash, minimums_hash_nil, stat_hits, StatsModule.return_batting_average_lambda, leader_is_highest_true, true)
	expect(leader_hash).to eq(challenger_hash_hits_high)
	
	eader_hash = ParserModule.challenger_beats_leader(challenger_hash_hits_low, leader_hash, minimums_hash_nil, stat_hits, StatsModule.return_batting_average_lambda, leader_is_highest_true, true)
	expect(leader_hash).to eq(leader_hash)
      end
    end
    
    it "should test for a triple crown winner using offensive_triple_crown_winner_by_year" do
      triple_crown_winner = ParserModule.offensive_triple_crown_winner_by_year(stat_rows, headers, year_2010, "AL")
      expect(triple_crown_winner).to eq({"AB"=>500, "H"=>100, "name"=>"name", "HR"=>10, "RBI"=>10})
      
      triple_crown_winner = ParserModule.offensive_triple_crown_winner_by_year(stat_rows, headers, year_2010, "NL")
      expect(triple_crown_winner).to eq(nil)

    end
    
    it "should use set_year_order, taking two integers and sorting them according to years_ascending" do
      year1, year2 = ParserModule.set_year_order(2010, 2011, true)
      expect(year1).to eq(2010)
      expect(year2).to eq(2011)
      
      year1, year2 = ParserModule.set_year_order(2010, 2011, false)
      expect(year1).to eq(2011)
      expect(year2).to eq(2010)
    end
  end
end