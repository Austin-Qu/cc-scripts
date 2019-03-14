# Styletread product rule scheduler issue

# [19] pry(main)> ProductRule.where(id:product_rule_ids).pluck(:product_level_id).group_by{|x|x}.collect{|x,c|[x,c.count]}
# => [[2, 62]]

codes = ["416", "418", "420", "422", "424", "426", "428", "430", "432", "434", "436", "438", "440", "442", "444", "446", "448", "450", "452", "454", "456", "458", "460", "462", "464", "881", "883", "885", "887", "889", "891", "893", "895", "897", "899", "901", "903", "905", "907", "909", "911", "913", "1478", "1480", "1548", "1732", "1734", "1740", "1742", "1744", "1746", "1748", "1750", "1752", "1754", "1756", "1758", "1760", "1762", "1881", "1927", "1943"]
product_rule_ids = ProductRule.where(code: codes).pluck(:id)
product_rules = ProductRule.where(id: product_rule_ids)
categories_to_delete = {}

cnt=0
total = Product.where(product_level_id:2).size

Product.where(product_level_id:2).each{ |p|
  del_categories = []
  data = p.children.first.sku_data.first.combined_data rescue nil
  next if data.nil?
  product_rules.each do |rule|
    outcome = rule.rule.render(data)
    del_categories << outcome if outcome.present?
    puts "==PRODUCT: #{p.id}====RULE: #{rule.id}===="
  end
  if del_categories.present?
    categories_to_delete[p.id] = del_categories
  end
  
  cnt+=1
  puts "-----progress: #{cnt}/#{total}----------"
}
