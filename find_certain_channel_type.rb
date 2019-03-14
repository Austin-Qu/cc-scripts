Tenant.all.each do | tenant |
  Apartment::Tenant.switch(tenant) do
    puts tenant.name if Channel.where(type: 'TheIconicChannel').size > 0
  end
end

Tenant.all.each do | tenant |
  Apartment::Tenant.switch(tenant) do
    puts tenant.name if ChannelCatalog.count > 0
  end
end
