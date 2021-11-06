require "json"
require "date"

# your code

data_file = File.new('data/input.json', "r")
data = JSON.load(data_file)
data_file.close

# making cars accessible as map (car_id > car)
cars = []
data['cars'].each do |car|
  cars[car['id']] = car;
end

# extracting rental information and storing it as a map
output = { 'rentals' => [] }
data['rentals'].each do |rental|
  # both first and last days are billed
  nb_days = (Date.parse(rental['end_date']) - Date.parse(rental['start_date'])).to_i + 1 
  price_per_day = cars[rental['car_id']]['price_per_day']
  price_per_km = cars[rental['car_id']]['price_per_km']
  nb_kms = rental['distance']

  price = nb_days * price_per_day + nb_kms * price_per_km
  output['rentals'].push('id' => rental['id'], 'price' => price)
end

# exporting rental info
out_file = File.new('myoutput.json', 'w')
JSON.dump(output, out_file)
out_file.close
