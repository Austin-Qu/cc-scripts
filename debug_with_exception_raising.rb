inventory_locations.each do |l|
  begin
    puts l.serializable_hash(hash_options)
  rescue
    binding.pry
    puts l.id
  end
end
