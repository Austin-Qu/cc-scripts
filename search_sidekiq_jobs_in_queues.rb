query = Sidekiq::RetrySet.new
ct=0

query.select do |job|
	if job.item['error_message'].include?("undefined method `stage__item' for")
	  job.delete
    ct+=1
  end
end