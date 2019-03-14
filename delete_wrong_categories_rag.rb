lookup = {
  brandid1 => cateset1,
  brandid2 => cartset2
}

br_cat_lookup = {
  "6": "6",
  "4": "3",
  "1": "1",
  "5": "5",
  "2": "2",
  "3": "4"
}

br_cat_lookup = br_cat_lookup.with_indifferent_access

taro_root_products = Product.where(brand_id: 6)

taro_style_wrong_categories_ids=[]

taro_root_products.each do |product|
  brand = product.brand_id
  cats = product.categories.where.not(category_set_id: br_cat_lookup[brand.to_s]).pluck(:id)
  taro_style_wrong_categories_ids << [product.id, cats]
end

cnt=0

taro_style_wrong_categories_ids.each do |e|
  cnt+=1 if e[1].size > 0
end

# style
taro_root_products.find_each(batch_size: 50) do |product|
  brand = product.brand_id
  cats = product.categories.where.not(category_set_id: br_cat_lookup[brand.to_s]).pluck(:id)
  FusionFactory::Versioning.delay_versioning(true) do
    ProductCategory.where(product_id:product.id, category_id: cats).destroy_all
  end
end

# color

taro_color_products = []
taro_root_products.find_each(batch_size: 50) {|p| taro_color_products << p.children}
taro_color_products.flatten!

taro_color_wrong_categories_ids=[]

taro_color_products.each_slice(50) do |slice|
  slice.each do |product|
    brand = product.parent.brand_id
    cats = product.categories.where.not(category_set_id: br_cat_lookup[brand.to_s]).pluck(:id)
    taro_color_wrong_categories_ids << [product.id, cats]
  end
end

cnt=0

taro_color_wrong_categories_ids.each do |e|
  cnt+=1 if e[1].size > 0
end

taro_color_products.each_slice(50) do |slice|
  slice.each do |product|
    brand = product.parent.brand_id
    cats = product.categories.where.not(category_set_id: br_cat_lookup[brand.to_s]).pluck(:id)
    FusionFactory::Versioning.delay_versioning(true) do
      ProductCategory.where(product_id:product.id, category_id: cats).destroy_all
    end
  end
end

# taro 914/2236 2603/3093

