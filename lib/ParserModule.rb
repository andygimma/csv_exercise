require_relative "./StatsModule"

module ParserModule
  include StatsModule
  
  def self.get_stat_by_team(stat_rows, headers, year, stat_name, team_name)
    stats_keys, minimums_hash, stats_lambda = StatsModule.constants_and_method_by_stat(stat_name)

    stats_hash = create_stats_hash(stats_keys, stat_name)

    stat_rows.select do |row|
      if match_year?(row, headers, year) and match_team?(row, headers, team_name)
	stats_keys = compile_stat_by_row(row, headers, minimums_hash, stats_hash)
      end
    end
    return stats_lambda.call(stats_hash), team_name, year
  end
  
#   def self.meaure_stat_by_row(row, headers, stats_hash, minimums_hash, stats_lambda)
#     get appropriate stats, check against minimum, and send if not minimum
#   end
  
  def self.compile_stat_by_row(row, headers, minimums_hash, stats_hash)
    # do we need minimums_hash?
    stats_hash.each do |key, value|
#       if minimums_hash.nil? == false and value < minimums_hash[key]
#       stats_hash[key] = stats_hash[key] + 0 ## TODO or maybe set this to nil. Let's find out which is more effective. Probably nil
      stats_hash[key] = stats_hash[key] + value_by_row(row, headers, key).to_i
    end
  end
  
  def self.value_by_row(row, headers, stat_name)
    return row[headers_index_by_stat_name(headers, stat_name)]
  end
  
  def self.match_team?(row, headers, team_name)
    return team_name == row[headers_index_by_stat_name(headers, "teamID")]
  end
  
  def self.match_year?(row, headers, year)
    return year.to_i == row[headers_index_by_stat_name(headers, "yearID")].to_i
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
end