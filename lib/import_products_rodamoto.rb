require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class ImportProductsRodamoto
  
  def initialize()
    @articulos = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo.dbf")
    @total = @articulos.count
  end
  
  def run
    i = j = n = 1
    @articulos.each do |articulo|
      unless articulo.baja == true || articulo.clacat == 15
        puts "Empiezo articulo #{articulo.codigo}"
        unless Spree::Variant.exists?(:sku => articulo.codigo)
          @product = Spree::Product.new
          @product.name = articulo.nombre
          @product.permalink = articulo.nombre.downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-')
          @product.count_on_hand = articulo.exmin
          
          @product.sku = articulo.codigo
          @product.price = articulo.pvp3
          @product.cost_price = articulo.pvp1
          @product.available_on = Date.today - 1.day
          @product.tire_width_id = set_width(articulo)
          @product.tire_profile_id = set_profile(articulo)
          @product.tire_innertube_id = set_innertube(articulo)
          @product.tire_ic_id = set_ic(articulo)
          @product.tire_speed_code_id = set_speed_code(articulo)
          @product.tire_fr_id = set_fr(articulo)
          @product.tire_tttl_id = set_tttl(articulo)
          
          @product.pvp3 = articulo.pvp3 * 1.18
          @product.pvp7 = articulo.pvp7 * 1.18
          @product.pvp9 = articulo.pvp9 * 1.18
          @product.pvp12 = articulo.pvp12 * 1.18
          
          @product.taxons << Spree::Taxon.find(set_catalog(articulo.clasub.to_i, articulo.clatipart.to_i, articulo.clacat.to_i))
          
          @product.taxons << Spree::Taxon.find(set_brand(articulo.clamar.to_i)) unless articulo.clamar.to_i == 0
          if @product.save!
            print "Grabado articulo #{i} de: #{@product.name} => Total de baja #{j} => Registro total #{i+j} de #{@total}" 
            print "\r"
            i += 1
          end
        end
        n += 1
        puts "Llevo #{n} articulos ya almacenados. Articulo #{articulo.codigo}"      
      end
      j += 1
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
        when 34
          return 16
        when 35
          return 18
        when 36
          return 20
        when 38
          return 22
        else
          return 23
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
            when 34
              return 17
            when 35
              return 20
            when 36
              return 23
            when 38
              return 26
          end
        when 81
          return 6
        when 82
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
    31 + clamar.to_i
  end
  
  def set_width(articulo)
    ancho = articulo.ancho
    ancho == "" ? ancho : Spree::TireWidth.find_by_name(ancho).id
  end
  
  def set_profile(articulo)
    perfil = articulo.perfil
    perfil == "" ? perfil : Spree::TireProfile.find_by_name(perfil).id
  end
  
  def set_innertube(articulo)
    llanta = articulo.llanta
    llanta == "" ? llanta : Spree::TireInnertube.find_by_name(llanta).id
  end
  
  def set_ic(articulo)
    ic = articulo.ic
    ic == "" ? ic : Spree::TireIc.find_by_name(ic).id
  end
  
  def set_speed_code(articulo)
    vel = articulo.vel
    vel == "" ? vel : Spree::TireSpeedCode.find_by_name(vel).id
  end
  
  def set_fr(articulo)
    fr = articulo.fr
    fr == "" ? fr : Spree::TireFr.find_by_name(fr).id
  end
  
  def set_tttl(articulo)
    tttl = articulo.tttl
    tttl == "" ? tttl : Spree::TireTttl.find_by_name(tttl).id
  end
end
