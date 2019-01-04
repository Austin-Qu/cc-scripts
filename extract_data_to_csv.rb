file_path = "/tmp/lj_ebay_au_report.csv"
channel_items = channel.channel_items.where(item_type: 0, external_status: 1)

CSV.open(file_path, 'wb') do |csv|
  csv << %w(product_code ebay_sku external_id name colour size quantity price)
  channel_items.find_each do |channel_item|
    puts channel_item.id
    data = channel_item.data
    variants = []
    if channel_item.data['Variations'].present?
      variants = channel_item.data['Variations']['Variation']
    end
    variants.each do |variant_data|
      colour = ''
      size = ''
      product_code = channel_item.extras[variant_data['SKU']].try(:[], 'code')
      variant_data['VariationSpecifics']['NameValueList'].each do  |name_value|
        if name_value['Name'] == 'Color'
          colour = name_value['Value']
        end
        if name_value['Name'] == 'Size'
          size = name_value['Value']
        end
      end if (variant_data['VariationSpecifics'].present? && variant_data['VariationSpecifics']['NameValueList'].present?)
      if variant_data.present?
        # puts [product_code, variant_data['SKU'], data['Title'], colour, size, variant_data['Quantity'], variant_data['StartPrice']]
        csv << [product_code, variant_data['SKU'], channel_item.external_id, data['Title'], colour, size, variant_data['Quantity'], variant_data['StartPrice']]
      end
    end if variants.present?

  end
end
