require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class ImportProductsRodamoto
  
  def initialize()
    articulos = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo.dbf")
  end
  
  def run
    for i in 1..5 do
      @product = Spree::Product.new
      @product.name = articulos.find(i).attributes["nombre"]
      @product.permalink = articulos.find(i).attributes["nombre"].downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-')
      @product.count_on_hand = 5
      @product.sku = articulos.find(i).attributes["codigo"]
      @product.price = articulos.find(i).attributes["pvp3"]
      @product.cost_price = articulos.find(i).attributes["pvp1"]
      @product.tire_width_id = Spree::TireWidth.find_by_name(articulos.find(i).attributes["ancho"].to_s).id
      @product.tire_profile_id = Spree::TireProfile.find_by_name(articulos.find(i).attributes["perfil"].to_s).id
      @product.tire_innertube_id = Spree::TireInnertube.find_by_name(articulos.find(i).attributes["llanta"].to_s).id
      @product.tire_ic_id = Spree::TireIc.find_by_name(articulos.find(i).attributes["ic"].to_s).id
      @product.tire_speed_code_id = Spree::TireSpeedCode.find_by_name(articulos.find(i).attributes["vel"].to_s).id
      @product.tire_fr_id = Spree::TireFr.find_by_name(articulos.find(i).attributes["fr"].to_s).id
      @product.tire_tttl_id = Spree::TireTttl.find_by_name(articulos.find(i).attributes["tttl"].to_s).id
      @product.taxons << set_catalog(articulos.find(i).attributes["clasub"], articulos.find(i).attributes["clatipart"], articulos.find(i).attributes["clacat"])
      @product.taxons << set_brand(articulos.find(i).attributes["clamar"])
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
  
end
