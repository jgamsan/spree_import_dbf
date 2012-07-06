require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class UpdateProductsRodamoto
  def initialize()
    @articulos = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo-nuevo.dbf")
    @list = @list_updated = []
    @clasub = [28, 29, 30]
    @clatipart = [80, 81, 82, 83, 64, 79, 65, 77, 78, 85, 84]
  end

  def run
    puts "Empezando tarea ........."
    Spree::Product.all.map { |x| @list << x.sku }
    
    @articulos.each do |articulo|
       unless articulo.baja == true || articulo.clacat == 15 || articulo.codigo == "" || get_catalog(articulo.clasub.to_i, articulo.clatipart.to_i, articulo.clacat.to_i) == true
         puts "Leyendo articulo #{articulo.codigo}"
         @list_updated << articulo.codigo 
       end
    end
    inter = @list & @list_updated
    borrar = @list - @list_updated
    nuevos = @list_updated - @list
    
    puts "Numero de articulos a actualizar #{inter.count}"
    puts "Numero de articulos a borrar #{borrar.count}"
    puts "Numero de articulos nuevos #{nuevos.count} "
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
end
