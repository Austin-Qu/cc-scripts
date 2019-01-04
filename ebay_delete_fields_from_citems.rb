DELETABLE_FIELDS = %w(ConditionID ItemSpecifics PayPalEmailAddress PostalCode SubTitle ProductListingDetails)

Ebay::Export::Scheduler.class_eval do
  def strip_transmit_data(channel_item, data, action)
    detailed_changeset = channel_item.detailed_changeset do |old_data,new_data|
      %w(ItemSpecifics ProductListingDetails ItemCompatibilityList PickupInStoreDetails).each do |key|
        old_data.delete(key)
        new_data.delete(key)
      end
    end
    changeset = channel_item.changeset
    alt_changeset = channel_item.alt_changeset
    previous_data = channel_item.previous_data

    data.except!('Status', 'Inventory')

    delete_fields = []

    DELETABLE_FIELDS.each do |field|
      if previous_data.has_key?(field) && !data.has_key?(field)
        delete_fields << "Item.#{field}"
      end
    end
    delete_fields << "Item.PictureDetails.PictureURL" if previous_data.has_key?('PictureDetails') && !data.has_key?('PictureDetails')

    detailed_data = {}
    %w(ItemSpecifics ProductListingDetails ItemCompatibilityList PickupInStoreDetails).each do |key|
      detailed_data[key] = data.delete(key)
    end


    previous_variations = previous_data['Variations']['Variation'].collect{|variation|variation['SKU']} rescue []
    current_variations = data['Variations']['Variation'].collect{|variation|variation['SKU']} rescue []
    if previous_variations.present? && (previous_variations - current_variations).present?
      data['Variations'] ||= {}
      data['Variations']['Variation'] ||= []
      (previous_variations - current_variations).each do |v|
        data['Variations']['Variation'] << {'SKU' => v, 'Delete'=> true }
      end
    end
    # delete keys here
    data.delete_if { |k, v| k == 'PrimaryCategory' || !(changeset['all'].include?(k) || (channel_item.disabled? && (k.end_with?('Quantity') || k.end_with?('Variations')))) }

    insert_details = ( data.present? || delete_fields.present? || detailed_data.any?{|key,value| value != previous_data[key]} )

    if insert_details
      detailed_data.each do |key,value|
        if key == 'ItemCompatibilityList'
          data[key] = (value||{}).merge(previous_data[key].present? ? {'ReplaceAll'=>true}:{}) if value != previous_data[key]
        else
          data[key] = value if value.present? # && key!='ProductListingDetails'
        end
      end
    end


    if action == :relist_fixed_price_item || data.present? || delete_fields.present?
      if channel_item.data['InventoryTrackingMethod'] == 'SKU'
        data['SKU'] = channel_item.data['SKU']
        data['InventoryTrackingMethod'] = 'SKU'
        data['ConditionID'] = 1000
      else
        data['ItemID'] = channel_item.external_id if channel_item.external_id.present?
      end

      {Item: data, DeletedField: delete_fields}
    else
      {}
    end
  end
end


################# staging after mokey patch the scheduler

item_ids=Channel.find(1).channel_items.where(status:0, external_status:1, export_status:6).pluck(:item_id).uniq
total = item_ids.count
cnt=0
item_ids.each_slice(5){|slice|
  Channel.find(1).stage(Item.where(id:slice))
  puts "\n\\n\n Processed #{cnt+=5}/#{total} \n\n\n"
}


