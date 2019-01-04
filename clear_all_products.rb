[MediaItem, Inventory,PriceItem, AttributeValue,InventoryDatum,ProductCategory, ProductCatalog, ProductGroup, ProductVariation, VirtualProduct].each{|klass|
  i=klass.pluck(:id)
  total=i.count
  cnt=0
  i.each_slice(50){|slice|klass.where(id:slice).delete_all;
  printf "\r Processed #{klass.to_s}.. #{cnt+=50}/#{total}.."}
}
 
# ==== Run this to skip SKU data generation if needed! ======
SkuDataDependency.module_eval do
  def update_sku_data(force = false)
    nil
  end
end
 
total = Product.count
cnt=0
Product.find_each(batch_size:50){|p|
  p.destroy
  printf "\r Destroyed #{cnt+=1}/#{total} products.."
}
