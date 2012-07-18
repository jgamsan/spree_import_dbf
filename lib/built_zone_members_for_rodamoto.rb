require 'csv'
require 'active_support'
require 'action_controller'
class BuiltZoneMembersForRodamoto
  
  def initialize()
    @file = "/home/jose/Documentos/rodamoto/zonas.csv"
    @file_final = "/home/jose/RubymineProjects/rodamoto/db/datas/zone_members.csv"
    @total = []
  end
  
  def run
    i = 0
    CSV.foreach(@file) do |row|
      codigo = Spree::Country.find_by_name(row[3]).id
      @total << [codigo, Spree::Country, row[1]]
      i += 1
      print "Almacenado #{row[3]}"
      print "\r"
    end
    CSV.open(@file_final, "wb") do |csv|
      @total.each do |row|
        csv << row
      end
    end
    puts "Grabados #{i} paises \n\n"
  end
  
end
