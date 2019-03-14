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

# arr = [...]
total = Product.count
cnt=0
Product.where(id: arr).find_each(batch_size:50){|p|
  begin
    p.destroy
  rescue ActiveRecord::InvalidForeignKey
    ProductDependentDatum.where(product_id: p.id).destroy_all
  end
  printf "\r Destroyed #{cnt+=1}/#{total} products.."
}
