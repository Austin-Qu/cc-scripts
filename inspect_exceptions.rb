def run(jid)
  begin
    last_rule_checked_at = last_checked_time || 10.years.ago
    current_time =  Time.current.utc
    product_rule = self.product_rule
    rule = product_rule.rule if product_rule.present?
    rule = update_rule(rule) if rule.present? # To update [0.days_ago]
    conditions = rule.content['rule']['conditions'] if rule.present?
    join = rule.content['rule']['join'] if rule.present?
    parsed_conditions = parse_conditions(conditions, join) if conditions.present? && join.present?
    ids = Product.with_translations(Globalize.locale).where(parsed_conditions).pluck(:root_id).uniq if parsed_conditions.present?  # Get products which are matching the condition
    ProductRule.perform_on_products({}, {'only'=>[rule.id]}, ids) if ids.present?
    self.update_attributes(last_checked_time: current_time)
  rescue Exception => e
    binding.pry
    raise e
  end
end




def parse_value(value, type)
  case type
  when 'boolean', 'number'
    value
  when 'datetime'
    # [14.days_ago]
    if value =~ /\A\[(.*)\]\z/
      commands = $1.split('.')
      case commands[1]
      when 'days_ago'
        "'#{commands[0].to_i.days.ago.strftime("%FT%T%:z")}'"
      else
        "'#{Time.now.strftime("%FT%T%:z")}'"
      end
    else
      "'#{Time.zone.parse(value).strftime("%FT%T%:z")}'"
    end
  else
    value.present? ? "'#{value}'" : value
  end
end
