require 'json'
require 'date'

class Car
  attr_reader :price_per_day, :price_per_km

  def initialize(attributes = {})
    @id = attributes['id']
    @price_per_day = attributes['price_per_day']
    @price_per_km = attributes['price_per_km']
  end
end

class Rental
  PAYMENT_TYPE = {
    driver: :debit,
    owner: :credit,
    insurance: :credit,
    assistance: :credit,
    drivy: :credit
  }

  attr_reader :id, :car_id, :start_date, :end_date, :distance

  def initialize(attributes = {})
    @id = attributes['id']
    @car_id = attributes['car_id']
    @start_date = attributes['start_date']
    @end_date = attributes['end_date']
    @distance = attributes['distance']
  end

  def car
    # Returns the object car associated with the current rental
    car_h = parse_input('cars').find { |c| c['id'] == car_id }
    Car.new(car_h)
  end

  def duration
    number_of_days(start_date, end_date)
  end

  def time_price
    price = car.price_per_day
    if duration / 11 >= 1
      price += 3 * price * 0.9 +
               6 * price * 0.7 +
               (duration % 11 + 1) * price * 0.5
    elsif duration / 5 >= 1
      price += 3 * price * 0.9 +
               (duration % 5 + 1) * price * 0.7
    elsif duration / 2 >= 1
      price += (duration % 2 + 1) * price * 0.9
    end
    price.to_i
  end

  def distance_price
    distance * car.price_per_km
  end

  def total_price
    time_price + distance_price
  end

  def commission
    insurance_fee = (0.3 * total_price / 2).to_i
    assistance_fee = (duration * 100).to_i
    {
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      drivy_fee: (0.3 * total_price - insurance_fee - assistance_fee).to_i
    }
  end

  def payment
    # This method calculates all the prices for each participant in the rental
    # and then returns an array of hashes, with who, type and amount keys
    # for each participant
    output = []
    payment_amount = {
      driver: total_price,
      owner: (0.7 * total_price).to_i,
      insurance: commission[:insurance_fee],
      assistance: commission[:assistance_fee],
      drivy: commission[:drivy_fee]
    }
    PAYMENT_TYPE.each do |who, type|
      output << {
        who: who,
        type: type,
        amount: payment_amount[who]
      }
    end
    output
  end

  private

  def number_of_days(start_date, end_date)
    (parse_date(end_date) - parse_date(start_date)).to_i + 1
  end

  def parse_date(date)
    Date.parse(date)
  end
end

def parse_input(data)
  # This method parses the input and returns the arrays asked
  # (be it cars or rentals)
  input_path = 'data/input.json'
  serialized_input = File.read(input_path)
  input = JSON.parse(serialized_input)
  input[data]
end

def save_json(output)
  h_output = {}
  h_output['rentals'] = output
  File.open('data/output.json', 'wb') do |file|
    file.write(JSON.pretty_generate(h_output))
  end
end

def process
  # This method builds the structure of the output and then calls #save_json
  # to actually save it in data/output.json
  output = []
  parse_input('rentals').each do |rental_h|
    rental = Rental.new(rental_h)
    output << {
      id: rental.id,
      actions: rental.payment
    }
  end
  save_json(output)
end

process
