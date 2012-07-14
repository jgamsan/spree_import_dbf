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
    @widths = CSV.read("#{Rails.root}/db/datas/anchos.csv").map {|x| x[0]}
    @profiles = CSV.read("#{Rails.root}/db/datas/perfiles.csv").map {|x| x[0]}
    @llantas = CSV.read("#{Rails.root}/db/datas/llantas.csv").map {|x| x[0]}
    @ics = CSV.read("#{Rails.root}/db/datas/ics.csv").map {|x| x[0]}
    @vel = CSV.read("#{Rails.root}/db/datas/vel.csv").map {|x| x[0]}
    @fr = CSV.read("#{Rails.root}/db/datas/fr.csv").map {|x| x[0]}
    @tttl = CSV.read("#{Rails.root}/db/datas/tttl.csv").map {|x| x[0]}
  end

  def run
    puts "Empezando tarea ........."
    productos = Spree::Variant.find_by_sql("Select is_master, sku from spree_variants where is_master = 't';")
    @list = productos.map {|x| x.sku}.flatten
    puts "Leidos los productos ......."
    CSV.foreach(@articulos, {headers: true}) do |row|
       unless row[73] == true || row[85] == 15 || row[1] == "" || get_catalog(row[84].to_i, row[83].to_i, row[85].to_i) == true
         puts "Leyendo articulo #{row[1]}"
         @list_updated << row[1] 
       end
    end
    inter = @list & @list_updated
    borrar = @list - @list_updated
    nuevos = @list_updated - @list
    actualizar = crear = []
    puts "Numero de articulos a actualizar #{inter.count}"
    puts "Numero de articulos a borrar #{borrar.count}"
    puts "Numero de articulos nuevos #{nuevos.count}"
    puts "Recargando Arrays"
    CSV.foreach(@articulos, {headers: true}) do |row|
      if inter.include?(row[1])
        actualizar << row
      end
      if nuevos.include?(row[1])
        crear << row
      end
    end
    #delete_items_action(borrar)
    #create_items_action(nuevos)
    update_items_action(actualizar)
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
    puts "ejecutando accion borrar"
    i = 0
    unless list.empty?
      list.each do |element|
        articulo = Spree::Variant.find_by_sku(element)
        producto = articulo.product
        producto.destroy
        i += 1
      end
    end
    puts "Borrados #{i} articulos"
  end
  
  def create_items_action(list)
    puts "ejecutando accion crear"
    i = 0
    unless list.empty?
      list.each do |element|
        @product = Spree::Product.new
        @product.name = row[2]
        @product.permalink = row[2].downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-')
        @product.count_on_hand = row[22]
        
        @product.sku = row[1]
        @product.price = row[52]
        @product.cost_price = row[6]
        @product.available_on = Date.today - 1.day
        @product.tire_width_id = set_width(row)
        @product.tire_profile_id = set_profile(row)
        @product.tire_innertube_id = set_innertube(row)
        @product.tire_ic_id = set_ic(row)
        @product.tire_speed_code_id = set_speed_code(row)
        @product.tire_fr_id = set_fr(row)
        @product.tire_tttl_id = set_tttl(row)
        
        @product.pvp3 = row[52] * 1.18
        @product.pvp7 = row[56] * 1.18
        @product.pvp9 = row[58] * 1.18
        @product.pvp12 = row[92] * 1.18
        
        @product.taxons << Spree::Taxon.find(set_catalog(row[84].to_i, row[83].to_i, row[85].to_i))
        
        @product.taxons << Spree::Taxon.find(set_brand(row[86].to_i)) unless row[86].to_i == 0
        if @product.save!
          puts "Creado articulo #{row[1]}"
          i += 1
        end
      end
    end
    puts "Creados #{i} articulos en total"
  end
  
  def update_items_action(list)
    puts "ejecutando accion actualizar"
    i = 0
    total = list.count
    unless list.empty?
      list.each do |row|  
        n = []
        codigo = row[1]
        articulo = Spree::Variant.find_by_sku(row[1])
        producto = articulo.product
        puts "Actualizando Codigo #{row[1]}"
        producto.update_attributes(
          :name => row[2],
          :permalink => row[2].downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-'),
          :count_on_hand => row[22].to_i,
          :sku => row[1],
          :price => row[52],
          :cost_price => row[6],
          :available_on => Date.today - 1.day,
          :tire_width_id => set_width(row),
          :tire_profile_id => set_profile(row),
          :tire_innertube_id => set_innertube(row),
          :tire_ic_id => set_ic(row),
          :tire_speed_code_id => set_speed_code(row),
          :tire_fr_id => set_fr(row),
          :tire_tttl_id => set_tttl(row),
          :pvp3 => row[52] * 1.18,
          :pvp7 => row[56] * 1.18,
          :pvp9 => row[58] * 1.18,
          :pvp12 => row[92] * 1.18
        )
        t = producto.taxons.map {|x| x.id}
        n << set_catalog(row[84].to_i, row[83].to_i, row[85].to_i)
        n << set_brand(row[86].to_i) unless row[86].to_i == 0
        unless t == n
          producto.taxons.delete_all
          producto.taxons << Spree::Taxon.find(set_catalog(row[84].to_i, row[83].to_i, row[85].to_i))
          producto.taxons << Spree::Taxon.find(set_brand(row[86].to_i)) unless row[86].to_i == 0
        end
        puts "Actualizado producto #{i} de #{total} productos: Codigo #{row[1]}"
        i += 1
      end
    end
  end
  
  def set_catalog(clasub, clatipart, clacat)
    if clacat == 21
      case clasub
        when 28
          10
        when 29
          4
        when 30
          13
      end
    else
      case clatipart
        when 73
          case clasub
            when 28
              10
            when 29
              5
            when 30
              14
          end
        when 81
          6
        when 82
          6
        when 83
          7
        when 80
          8
        when 64
          16
        when 79
          17
        when 65
          18
        when 77
          19
        when 78
          20
        when 85
          21
        when 84
          22
      end
    end
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
  
  def set_brand(clamar)
    22 + clamar.to_i
  end
  
  def set_width(articulo)
    ancho = articulo[113]
    ancho == "" ? ancho : @widths.index(ancho) + 1
  end
  
  def set_profile(articulo)
    perfil = articulo[115]
    perfil == "" ? perfil : @profiles.index(perfil) + 1
  end
  
  def set_innertube(articulo)
    llanta = articulo[117]
    llanta == "" ? llanta : @llantas.index(llanta) + 1
  end
  
  def set_ic(articulo)
    ic = articulo[118]
    ic == "" ? ic : @ics.index(ic) + 1
  end
  
  def set_speed_code(articulo)
    vel = articulo[119]
    vel == "" ? vel : @vel.index(vel) + 1
  end
  
  def set_fr(articulo)
    fr = articulo[120]
    fr == "" ? fr : @fr.index(fr) + 1
  end
  
  def set_tttl(articulo)
    tttl = articulo[121]
    tttl == "" ? tttl : @tttl.index(tttl) + 1
  end
end
