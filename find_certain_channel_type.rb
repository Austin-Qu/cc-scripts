Tenant.where(version: 5).each do | tenant |
  Apartment::Tenant.switch(tenant) do
    puts tenant.name if Channel.where(type: 'AnatwineChannel').size > 0
  end
end
