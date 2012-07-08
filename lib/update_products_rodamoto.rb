require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class UpdateProductsRodamoto

  def initialize()
    @articulos = "/home/jose/RubymineProjects/articulos-nuevos.csv"
    @list = @list_updated = []
    @clasub = [28, 29, 30]
    @clatipart = [80, 81, 82, 83, 64, 79, 65, 77, 78, 85, 84]
  end

  def run
    puts "Empezando tarea ........."
    Spree::Product.all.map { |x| @list << x.sku }
    puts "Leidos los productos ......."
    CSV.foreach(@articulos) do |row|
       unless row[73] == true || row[85] == 15 || row[1] == "" || get_catalog(row[84].to_i, row[83].to_i, row[85].to_i) == true
         puts "Leyendo articulo #{row[1]}"
         @list_updated << row[1] 
       end
    end
    inter = @list & @list_updated
    borrar = @list - @list_updated
    nuevos = @list_updated - @list
    
    puts "Numero de articulos a actualizar #{inter.count}"
    puts "Numero de articulos a borrar #{borrar.count}"
    puts "Numero de articulos nuevos #{nuevos.count}"
    
    delete_items_action(borrar)
    create_items_action(nuevos)
    update_items_action(nuevos)
  end
  
  def get_catalog(clasub, clatipart, clacat)
    if clacat == 21
      if @clasub.include?(clasub)
        return false
      else
        return true
      end
    else
      if clatipart == 73
        if @clasub.include?(clasub)
          return false
        else
          return true
        end
      else
        if @clatipart.include?(clatipart)  
          return false
        else
          return true
        end
      end
    end
  end
  
  def delete_items_action(list)
    puts "ejecutado accion borrar"
  end
  
  def create_items_action(list)
    puts "ejecutado accion crear"
  end
  
  def update_items_action(list)
    puts "ejecutado accion actualizar"
  end
end
