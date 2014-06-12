module StatsModule
  # required minimums for each compiled stat
  BATTING_AVERAGE_MINIMUMS = { "AB" => 400 }
  SLUGGING_PERCENTAGE_MINIMUMS = nil
  
  # stats needed for each compiled stat
  BATTING_AVERAGE_STATS = ["AB", "H"]
  SLUGGING_PERCENTAGE_STATS = ["AB", "H", "2B", "3B", "HR"]
  
  # stat lambdas to pass around code blocks
  BATTING_AVERAGE_LAMBDA = lambda do |stats_hash|
    # check only two stats, and they are :ab and :h, round to the third decimal place
    return (stats_hash["H"].to_f/stats_hash["AB"].to_f).round(3)
  end
  
  SLUGGING_PERCENTAGE_LAMBDA = lambda do |stats_hash|
    return ((stats_hash["H"] + stats_hash["2B"] + stats_hash["3B"] * 2 + stats_hash["HR"] * 3.to_f) / stats_hash["AB"].to_f).round(3)
  end
  
  MISCELLANEOUS_STATS_LAMNDA = lambda do |stats_hash|
    return stats_hash
  end
  
  # return lambdas via a function. Looks cleaner and allows more granular testing
  def self.return_batting_average_lambda
    return BATTING_AVERAGE_LAMBDA
  end
  
  def self.return_slugging_percentage_lambda
    return SLUGGING_PERCENTAGE_LAMBDA
  end
  
  def self.return_miscellaneous_stats_lambda
    return MISCELLANEOUS_STATS_LAMNDA
  end
  
  
  
  # return constants based on stat case. If case not met, return nil values
  def self.constants_and_method_by_stat(stat)
    case stat
    when "BA"
      stats = BATTING_AVERAGE_STATS
      mins = BATTING_AVERAGE_MINIMUMS
      method = return_batting_average_lambda
      
      return stats, mins, method
    when "SLG"
      stats = SLUGGING_PERCENTAGE_STATS
      mins = SLUGGING_PERCENTAGE_MINIMUMS
      method = return_slugging_percentage_lambda
      
      return stats, mins, method
    else
      return nil, nil, return_miscellaneous_stats_lambda
    end
  end
end