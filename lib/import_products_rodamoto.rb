require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class ImportProductsRodamoto
  
  def initialize()
    @articulos = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo.dbf")
  end
  
  def run
    for i in 1..100 do
      unless @articulos.find(i).attributes["baja"] == true
        @product = Spree::Product.new
        @product.name = @articulos.find(i).attributes["nombre"]
        @product.permalink = @articulos.find(i).attributes["nombre"].downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-')
        @product.count_on_hand = 5
        @product.sku = @articulos.find(i).attributes["codigo"]
        @product.price = @articulos.find(i).attributes["pvp3"]
        @product.cost_price = @articulos.find(i).attributes["pvp1"]
        
        @product.tire_width_id = set_width(i)
        @product.tire_profile_id = set_profile(i)
        @product.tire_innertube_id = set_innertube(i)
        @product.tire_ic_id = set_ic(i)
        @product.tire_speed_code_id = set_speed_code(i)
        @product.tire_fr_id = set_fr(i)
        @product.tire_tttl_id = set_tttl(i)
        
        @product.taxons << Spree::Taxon.find(set_catalog(@articulos.find(i).attributes["clasub"].to_i, @articulos.find(i).attributes["clatipart"].to_i, @articulos.find(i).attributes["clacat"].to_i))
        
        @product.taxons << Spree::Taxon.find(set_brand(@articulos.find(i).attributes["clamar"].to_i))
        if @product.save!
          print "grabado articulo" + @product.name
        end      
      end
    end
  end
  
  def set_catalog(clasub, clatipart, clacat)
    if clacat == 21
      case clasub
        when 28
          return 10
        when 29
          return 4
        when 30
          return 13
      end
    else
      case clatipart
        when 73
          case clasub
            when 28
              return 10
            when 29
              return 5
            when 30
              return 14
          end
        when 81
          return 6
        when 83
          return 7
        when 80
          return 8
        when 64
          return 16
        when 79
          return 17
        when 65
          return 18
        when 77
          return 19
        when 78
          return 20
        when 85
          return 21
        when 84
          return 22   
      end
    end
  end
  
  def set_brand(clamar)
    22 + clamar.to_i
  end
  
  def set_width(i)
    ancho = @articulos.find(i).attributes["ancho"]
    ancho == "" ? ancho : Spree::TireWidth.find_by_name(ancho.to_s).id
  end
  
  def set_profile(i)
    perfil = @articulos.find(i).attributes["perfil"]
    perfil == "" ? perfil : Spree::TireProfile.find_by_name(perfil.to_s).id
  end
  
  def set_innertube(i)
    llanta = @articulos.find(i).attributes["llanta"]
    llanta == "" ? llanta : Spree::TireInnertube.find_by_name(llanta.to_s).id
  end
  
  def set_ic(i)
    ic = @articulos.find(i).attributes["ic"]
    ic == "" ? ic : Spree::TireIc.find_by_name(ic.to_s).id
  end
  
  def set_speed_code(i)
    vel = @articulos.find(i).attributes["vel"]
    vel == "" ? vel : Spree::TireSpeedCode.find_by_name(vel.to_s).id
  end
  
  def set_fr(i)
    fr = @articulos.find(i).attributes["fr"]
    fr == "" ? fr : Spree::TireFr.find_by_name(fr.to_s).id
  end
  
  def set_tttl(i)
    tttl = @articulos.find(i).attributes["tttl"]
    tttl == "" ? tttl : Spree::TireTttl.find_by_name(tttl.to_s).id
  end
end
