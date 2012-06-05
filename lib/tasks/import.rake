namespace :products do

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
      csv << ["product", "parent_sku", "id", "sku", "name", "permalink", "quantity", "description", "prototype", "category", "gender", "tax_category", "shipping_category", "deleted_at", "shipping_time", "style", "frame_width", "frame_type", "frame_shape", "bridge_width", "eye_size", "arm_length", "image", "image2", "image3", "meta_description", "meta_keywords", "delete"]
	  
	  @products.each do |p|
      csv << ["Product", 
        "",
        p.id,
        p.sku 
        p.name, 
        p.permalink, 
        p.count_on_hand, 
        p.description, 
        "prototype", 
        "category", 
        "gender", 
        p.tax_category.name, 
        p.shipping_category.name,
        p.deleted_at 
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
        p.deleted_at
        p.sku,           
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
