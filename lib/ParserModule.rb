require_relative "./StatsModule"

module ParserModule
  include StatsModule
  
  def self.get_stat_by_team(stat_rows, headers, year, stat_name, team_name)
    stats_keys, minimums_hash, stats_lambda, complex_stat = StatsModule.constants_and_method_by_stat(stat_name)

    stats_hash = create_stats_hash(stats_keys, stat_name)

    stat_rows.select do |row|
      if match_year?(row, headers, year) and match_team?(row, headers, team_name)
	stats_keys = compile_stat_by_row(row, headers, minimums_hash, stats_hash)
      end
    end
    return stats_lambda.call(stats_hash), team_name, year
  end
  
  
  def self.stat_leader(stat_rows, headers, year, stat_name, league, leader_is_highest)    
    leader_hash = nil
    stats_keys, minimums_hash, stats_lambda, complex_stat = StatsModule.constants_and_method_by_stat(stat_name)
    stats_hash = create_stats_hash(stats_keys, stat_name)
    stat_rows.select do |row|
      if match_year?(row, headers, year) and match_league?(row, headers, league)
        challenger_hash = return_stat_by_row(row, headers, minimums_hash, stats_hash)
	leader_hash = challenger_beats_leader(challenger_hash, leader_hash, stat_name, stats_lambda, leader_is_highest, complex_stat)
      end

    end
    return leader_hash
  end
  
  def self.compile_stat_by_row(row, headers, minimums_hash, stats_hash)
    stats_hash.each do |key, value|
      stats_hash[key] = value + value_by_row(row, headers, key).to_i
    end
    return stats_hash
  end
  
  def self.return_stat_by_row(row, headers, minimums_hash, stats_hash)
    stats_hash.each do |key, value|
      stats_hash[key] = value_by_row(row, headers, key).to_i
    end
    stats_hash["name"] = value_by_row(row, headers, "playerID")
    return stats_hash
  end
  
  def self.value_by_row(row, headers, stat_name)
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
  
  def self.challenger_beats_leader(challenger_hash, leader_hash, stat_name, stats_lambda, leader_is_highest, complex_stat)
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
    end
  end
end