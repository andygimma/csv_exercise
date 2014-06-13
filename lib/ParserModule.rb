require_relative "./StatsModule"

module ParserModule
  include StatsModule

  def self.get_stat_by_team(stat_rows, headers, year, stat_name, team_name)
    stats_keys, minimums_hash, stats_lambda, complex_stat = StatsModule.constants_and_method_by_stat(stat_name)

    stats_hash = create_stats_hash(stats_keys, stat_name)

    stat_rows.select do |row|
      if match_year?(row, headers, year) and match_team?(row, headers, team_name)
	stats_keys = compile_stat_by_row(row, headers, stats_hash)
      end
    end
    return stats_lambda.call(stats_hash), team_name, year, stat_name
  end
  
  def self.stat_leader(stat_rows, headers, year, stat_name, league, leader_is_highest)    
    leader_hash = nil
    stats_keys, minimums_hash, stats_lambda, complex_stat = StatsModule.constants_and_method_by_stat(stat_name)
    stats_hash = create_stats_hash(stats_keys, stat_name)
    stat_rows.select do |row|
      if match_year?(row, headers, year) and match_league?(row, headers, league)
        challenger_hash = return_stat_by_row(row, headers, stats_hash)
	leader_hash = challenger_beats_leader(challenger_hash, leader_hash, minimums_hash, stat_name, stats_lambda, leader_is_highest, complex_stat)
      end

    end
    return leader_hash
  end
  
  def self.get_stat_increase_leader(stat_rows, headers, year1, year2, stat_name, years_ascending = false)
    stats_keys, minimums_hash, stats_lambda, complex_stat = StatsModule.constants_and_method_by_stat(stat_name)
    stats_hash = create_stats_hash(stats_keys, stat_name)
    
    year1, year2 = set_year_order(year1, year2, years_ascending)
    leader_hash = {"playerID" => nil, "stat_name" => stat_name, "difference" => -1}
    year1_hash = {}
    year2_hash = {}
    stat_rows.select do |row|
      if match_year?(row, headers, year1)
	year1_hash = return_stat_by_row(row, headers, stats_hash)
      end
      
      if match_year?(row, headers, year2)
	# TODO fix .dup
	y1 = year1_hash.dup
	year2_hash = return_stat_by_row(row, headers, stats_hash)
	difference =  compare_increase(y1, year2_hash, stat_name, minimums_hash, stats_lambda, complex_stat, leader_hash)
	if !difference.nil?
	  leader_hash = {"playerID" => value_by_row(row, headers, "playerID"), "stat_name" => stat_name, "difference" => difference}
	end
      end
    end
    return leader_hash
  end
  
  def self.compile_stat_by_row(row, headers, stats_hash)
    stats_hash.each do |key, value|
      stats_hash[key] = value + value_by_row(row, headers, key).to_i
    end
    return stats_hash
  end
  
  def self.return_stat_by_row(row, headers, stats_hash)
    stats_hash.each do |key, value|
      stats_hash[key] = value_by_row(row, headers, key).to_i
    end
    stats_hash["name"] = value_by_row(row, headers, "playerID")
    return stats_hash
  end
  
  def self.value_by_row(row, headers, stat_name)
    if headers_index_by_stat_name(headers, stat_name).nil?
      return nil
    end
    return row[headers_index_by_stat_name(headers, stat_name)]
  end
  
  def self.match_team?(row, headers, team_name)
    return team_name.to_s == row[headers_index_by_stat_name(headers, "teamID")].to_s
  end
  
  def self.match_year?(row, headers, year)
    return year.to_i == row[headers_index_by_stat_name(headers, "yearID")].to_i
  end
  
  def self.match_league?(row, headers, league)
    return league.to_s == row[headers_index_by_stat_name(headers, "league")].to_s

  end
  def self.headers_index_by_stat_name(headers, stat_name)
    return headers.index(stat_name)
  end
  
  def self.create_stats_hash(stats_keys, stat_name)
    if stats_keys.nil?
      stats_hash = { stat_name => 0 }
    else
      stats_hash = Hash[stats_keys.map {|v| [v,0]}]
    end
  end
  
  def self.challenger_beats_leader(challenger_hash, leader_hash, minimums_hash, stat_name, stats_lambda, leader_is_highest, complex_stat)
    if complex_stat.nil?
      if leader_hash.nil?
	leader_hash = challenger_hash.dup
      end
      if leader_is_highest and leader_hash[stat_name] < challenger_hash[stat_name]
	leader_hash = challenger_hash.dup
      end     
      return leader_hash
    else
      if leader_hash.nil?
	leader_hash = challenger_hash.dup
      end
      if stats_lambda.call(leader_hash).nan?
	leader_hash = challenger_hash.dup
      end
      if stats_lambda.call(leader_hash).nan?
	leader_hash = leader_hash.dup
      end
      if leader_is_highest and meets_minimums?(challenger_hash, minimums_hash) and stats_lambda.call(challenger_hash) > stats_lambda.call(leader_hash)
	leader_hash = challenger_hash.dup
	leader_hash[stat_name] = stats_lambda.call(challenger_hash)
      end
      return leader_hash
    end 
  end
  
  def self.meets_minimums?(stats_hash, minimums_hash)
    if minimums_hash.nil? == false
      minimums_hash.each do |key, value|
	if minimums_hash[key].to_f > stats_hash[key].to_f
	  return false
	end
      end
    end
    return true
  end
  
  def self.offensive_triple_crown_winner_by_year(csv_file, headers, year, league)
    hr_leader =  stat_leader(csv_file, headers, year, "HR", league, true)
    rbi_leader = stat_leader(csv_file, headers, year, "RBI", league, true)
    
    if hr_leader["name"] == rbi_leader["name"]
      avg_leader = stat_leader(csv_file, headers, year, "BA", league, true)
      if hr_leader["name"] == avg_leader["name"]
	triple_crown_winner = avg_leader.dup
	triple_crown_winner["HR"] = hr_leader["HR"]
	triple_crown_winner["RBI"] = rbi_leader["RBI"]
	return triple_crown_winner
      end
    end
    return nil
  end
  
  def self.set_year_order(year1, year2, years_ascending)
    if years_ascending
      first_year = year1 > year2 ? year2 : year1
      second_year = year1 > year2 ? year1 : year2
    else
      first_year = year1 > year2 ? year1 : year2
      second_year = year1 > year2 ? year2 : year1
    end
    return first_year, second_year
  end
  
  def self.compare_increase(year1_hash, year2_hash, stat_name, minimums_hash, stats_lambda, complex_stat, leader_hash)
    if meets_minimums?(year1_hash, minimums_hash) and meets_minimums?(year2_hash, minimums_hash)
      if complex_stat
	if year1_hash["playerID"] == year2_hash["playerID"]
	  difference = stats_lambda.call(year2_hash) - stats_lambda.call(year1_hash)
	  if difference > leader_hash["difference"]
	    return difference
	  end
	end
      else
	if year1_hash["playerID"] == year2_hash["playerID"]
	  difference = year2_hash[stat_name].to_i - year1_hash[stat_name].to_i
	  if difference > leader_hash["difference"]
	    return difference
	  end
	end
	
      end
	
    end
    return nil
  end
end