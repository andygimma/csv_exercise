require_relative '../lib/StatsModule'

describe StatsModule do
  include StatsModule
  
  let(:stats_hash_return_batting_average) { {"AB" => 100, "H" => 10} }
  let(:stats_hash_return_slugging_percentage) { {"AB" => 320, "H" => 100, "2B" => 10, "3B" => 10, "HR" => 10} }
  
  it "should provide minimums for batting average" do
    batting_average_minimums =StatsModule::BATTING_AVERAGE_MINIMUMS
    expect(batting_average_minimums.empty?).to eq(false)
  end
  
  it "should provide minimums for slugging percentage" do
    slugging_percentage_minimums =StatsModule::SLUGGING_PERCENTAGE_MINIMUMS
    expect(slugging_percentage_minimums.nil?).to eq(false)
  end
  
  it "should return a batting average lambda, that correctly calculates batting average" do
    stats_hash = stats_hash_return_batting_average
    ba_lambda = StatsModule.return_batting_average_lambda
    average = ba_lambda.call(stats_hash)
    expect(average).to eq(0.100)
  end
  
  it "should return a slugging percentage lambda, that correctly calculates slugging percentage" do
    stats_hash = stats_hash_return_slugging_percentage
    ba_lambda = StatsModule.return_slugging_percentage_lambda
    slugging = ba_lambda.call(stats_hash)
    expect(slugging).to eq(0.500)
  end
  
  context "if the case method is matched with BA return constants_and_method_by_stat with proper variables" do
    it "should return stats, mins and method for each stat" do
      stats, min, method = StatsModule.constants_and_method_by_stat("BA")
      expect(stats).to eq(["AB", "H"])
      expect(min).to eq({"AB" => 200})
      expect(min).to eq({ "AB" => 200 })
    end
  end
  
  context "if the case method is matched with SLG return constants_and_method_by_stat with proper variables" do
    it "should return stats, mins and method for each stat" do
      stats_hash = stats_hash_return_slugging_percentage
      stats, min, method = StatsModule.constants_and_method_by_stat("SLG")
      expect(stats).to eq(["AB", "H", "2B", "3B", "HR"])
      expect(min).to eq({"AB" => 200})
    end
  end
  context "if the case method is not matched in constants_and_method_by_stat" do
    it "should return nil for stats, mins. Make sure the method returned is not nil." do
      stats, min, method = StatsModule.constants_and_method_by_stat("Not a match")
      expect(stats).to eq(nil)
      expect(min).to eq(nil)
      expect(method.nil?).to eq(false)  
    end  
  end
end