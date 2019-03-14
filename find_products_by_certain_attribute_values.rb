# V5 only
AttributeValue.where(attribute_definition_id: 4).select{|v| upcas.include? v.data}.collect(&:product_id)
