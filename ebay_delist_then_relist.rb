c=Channel.find(1)
s=c.scheduler
File.open('/tmp/sparebox.txt').each{|code|
arr.each {|code|
  ci = ChannelItem.where(external_id: code).first
  if ci.present?
    if ci.added?
      ci.update(status: 'inactive')
      s.schedule(ci)
    else
      ci.update(external_status: 'deleted')
    end
  end 
}

cis.find_each(batch_size: 50) do |ci|
  ci.update(status: 'inactive')
  s.schedule(ci)
end

# cis.find_each(batch_size: 50) do |ci|
#   ci.update(status: 'active')
#   s.schedule(ci)
# end

# Kick off the eBay transmit Job


File.open('/tmp/sparebox.txt').each{|code|
  ci = ChannelItem.where(external_id: code).first
  if ci.present?
    if ci.ended?
      ci.item.channel_items.where(external_status: 3).update_all(external_status: 4)
      c.stage(ci.item)
    end
  end 
}


arr[123201..125507].each_slice(50).with_index {|slice, idx| #400
  slice.each do |code|
    ci = ChannelItem.where(external_id: code).first
    if ci.present?
      if ci.ended?
        ci.item.channel_items.where(external_status: 3).update_all(external_status: 4)
        c.stage([ci.item])
      end
    end
    
    puts "================================================="
    puts "==================SLICE #{idx}==================="
    puts "================================================="
  end
}