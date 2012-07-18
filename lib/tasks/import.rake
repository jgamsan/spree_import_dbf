namespace :products do

  desc "Import products to spree database."
  task :to_rodamoto => :environment do
    require 'import_products_rodamoto'
    ImportProductsRodamoto.new.run
  end
  
  desc "Update products to spree database."
  task :update_rodamoto => :environment do
    require 'update_products_rodamoto'
    UpdateProductsRodamoto.new.run
  end
  
  
  desc "Import habtm to spree database."
  task :to_habtm => :environment do
    require 'set_habtm_for_rodamoto'
    SetHabtmForRodamoto.new.run
  end
  
  desc "Built Zones.csv"
  task :built_zones => :environment do
    require 'built_zones_for_rodamoto'
    BuiltZonesForRodamoto.new.run
  end
  
  desc "Built Zone_members.csv"
  task :built_zone_members => :environment do
    require 'built_zone_members_for_rodamoto'
    BuiltZoneMembersForRodamoto.new.run
  end
  
  desc "Make a txt/csv file."
  task :to_csv  => :environment do
    require 'my_import_products'
    @dir = Dir.glob(File.join(Rails.root, "vendor", "exports", "products" ))
    articulos = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo.dbf")
    CSV.open("#{Rails.root}/vendor/exports/products/products-#{DateTime.now.strftime('%H-%M-%S-%d-%m-%Y')}.csv", "w") do |csv|
      csv << ["product", "", "sku", "name", "permalink", "quantity", "description", "prototype", "category", "gender", "tax_category", "shipping_category", "deleted_at", "shipping_time", "style", "frame_width", "frame_type", "frame_shape", "bridge_width", "eye_size", "arm_length", "image", "image2", "image3", "meta_description", "meta_keywords", "delete", "price", "weight", "height", "width", "depth", "cost_price"]
      articulos.each do |articulo|
        csv << ["Product", 
        "",
        articulo.codigo, 
        articulo.nombre, 
        articulo.nombre.downcase.gsub(/\s+/, '-').gsub(/[^a-zA-Z0-9_]+/, '-'), 
        articulo.exmin, 
        "", 
        "prototype", 
        "category", 
        "gender", 
        "", 
        "",
        Date.today + 1.year, 
        "ship time", 
        "style", 
        "frame_width", 
        "frame_type", 
        "frame_shape", 
        "bridge_width", 
        "eye_size", 
        "arm_length", 
        "", 
        "", 
        "", 
        "", 
        "", 
        Date.today + 1.year,          
        articulo.pvp1.to_s,
        "",
        "",
        "",
        "",
        articulo.costereal,
        ]
      end
    end
  end
  
  desc "Load a txt/csv file."
  task :import  => :environment do
    require 'my_import_products'
    MyImportProducts.new.run
  end
  
  task :export  => :environment do
  @dir = Dir.glob(File.join(Rails.root, "vendor", "exports", "products" ))
  @products = Spree::Product.find(:all)
  puts "Saving file to #{@dir}"
  
  def brand_name
    taxons.select {|t| t.parent.name == 'Brands' }.first.try(:name)
  end
  
  CSV.open("#{Rails.root}/vendor/exports/products/products-#{DateTime.now.strftime('%H-%M-%S-%d-%m-%Y')}.csv", "w") do |csv|
    # header row
      csv << ["product", "", "id", "sku", "name", "permalink", "quantity", "description", "prototype", "category", "gender", "tax_category", "shipping_category", "deleted_at", "shipping_time", "style", "frame_width", "frame_type", "frame_shape", "bridge_width", "eye_size", "arm_length", "image", "image2", "image3", "meta_description", "meta_keywords", "delete", "price", "weight", "height", "width", "depth", "cost_price"]
	  
	  @products.each do |p|
      csv << ["Product", 
        "",
        p.id,
        p.sku, 
        p.name, 
        p.permalink, 
        p.count_on_hand, 
        p.description, 
        "prototype", 
        "category", 
        "gender", 
        !p.tax_category.nil? ? p.tax_category.name : "", 
        !p.shipping_category.nil? ? p.shipping_category.name : "",
        p.deleted_at, 
        "ship time", 
        "style", 
        "frame_width", 
        "frame_type", 
        "frame_shape", 
        "bridge_width", 
        "eye_size", 
        "arm_length", 
        !p.images[0].nil? ? p.images[0].attachment.original_filename : "", 
        !p.images[1].nil? ? p.images[1].attachment.original_filename : "", 
        !p.images[2].nil? ? p.images[2].attachment.original_filename : "", 
        p.meta_description, 
        p.meta_keywords, 
        p.deleted_at,          
        p.price.to_s,
        p.weight,
        p.height,
        p.width,
        p.depth,
        p.cost_price,
        ]
		
		if p.has_variants?
      puts p.name
      p.variants.each do |variant|
        puts  variant.sku
        if variant.option_values[0].nil?
          measure = nil
        else
          measure =  variant.option_values[0].presentation
        end
          csv << ["Variant",
            variant.position,
            variant.id,
            variant.sku,
            variant.is_master,                   
            variant.product_id,
            variant.price.to_s,
            variant.count_on_hand,
            variant.weight,
            variant.height,
            variant.width,
            variant.depth,
            variant.cost_price,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            !variant.images[0].nil? ? variant.images[0].attachment.original_filename : "", 
            !variant.images[1].nil? ? variant.images[1].attachment.original_filename : "", 
            !variant.images[2].nil? ? variant.images[2].attachment.original_filename : "", 
            nil,
            nil,
            nil,
            variant.deleted_at]
          end
        end
      end
    end
  end

end
