# for large amount stage, increase CM sidekiq thread max number as well

item_ids.each_slice(15) do |slice|
  BatchStager.perform_async(1, slice)
end