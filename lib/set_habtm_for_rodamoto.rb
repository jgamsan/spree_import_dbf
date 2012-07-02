require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess


class SetHabtmForRodamoto

  def initialize()
    @file = "/home/jose/RubymineProjects/archivos/habtm.csv"
    @file_final = "/home/jose/RubymineProjects/habtm_final.csv"
    @total = []
    @row_new = []
  end
  
  def run
    i = 1
    CSV.foreach(@file) do |row|
      print "Item tratado #{i}"
      print "\r" 
      if row[0] == nil
        @row_new[0] = ""
      else
        @row_new[0] = Spree::TireWidth.find_by_name(row[0].to_s).id
      end
      if row[1] == nil
        @row_new[1] = ""
      else
        @row_new[1] = Spree::TireProfile.find_by_name(row[1].to_s).id
      end
      if row[2] == nil
        @row_new[2] = ""
      else
        @row_new[2] = Spree::TireInnertube.find_by_name(row[2].to_s).id
      end
      if row[3] == nil
        @row_new[3] = ""
      else
        @row_new[3] = Spree::TireIc.find_by_name(row[3].to_s).id
      end
      if row[4] == nil
        @row_new[4] = ""
      else
        @row_new[4] = Spree::TireSpeedCode.find_by_name(row[4].to_s).id
      end
      if row[5] == nil
        @row_new[5] = ""
      else
        @row_new[5] = Spree::TireFr.find_by_name(row[5].to_s).id
      end
      if row[6] == nil
        @row_new[6] = ""
      else
        @row_new[6] = Spree::TireTttl.find_by_name(row[6].to_s).id
      end
      @total << [@row_new[0], @row_new[1], @row_new[2], @row_new[3], @row_new[4], @row_new[5], @row_new[6]]
      i += 1
    end
    CSV.open(@file_final, "wb") do |csv|
      @total.each do |row|
        csv << row
      end
    end
  end
  
end
