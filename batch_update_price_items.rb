pids = PriceItem.where(from: (Time.parse "2017-07-09T14:00:00.000Z"), to: (Time.parse "2099-12-30T14:00:00.000Z")).pluck('distinct product_id');nil

total = pids.count
cnt = 0
correct_to = (Time.parse "2019-01-06T14:00:00.000Z")
incorrect_from = Time.parse "2017-07-09T14:00:00.000Z"
incorrect_to= Time.parse "2099-12-30T14:00:00.000Z"
pids.each_slice(3){|pids|
  ::FusionFactory::Versioning.delay_versioning(true) do
    PriceItem.where(product_id: pids, from: incorrect_from, to: incorrect_to).each{|pi|
     pi.update(to: correct_to)
    }
    printf "\r Processed #{cnt+=1}/#{total}..."
  end
}

# ========api_job way============

PriceItem.where(from: (Time.parse "2017-07-09T14:00:00.000Z"), to: (Time.parse "2099-12-30T14:00:00.000Z")).find_in_batches(batch_size:50){|items|
  data = items.collect{|pi|
   {id: pi.id, amount: pi.amount, to: Time.parse("2019-01-06T14:00:00.000Z")}
  }
  ::ApiJob.create_job('cc_support', 'PriceItem', ::ApiJob.formats[:json], 'upsert', data)
}
