require 'erb'
require 'csv'

hashdata = CSV.read("planet_express_logs.csv", header_converters: :symbol, converters: :numeric,  headers:true).map{|x| x.to_hash}


class Delivery

  attr_accessor :destination, :shipment, :crates, :money, :pilot

  def initialize(hash)
    @destination = hash[:destination]
    @shipment = hash[:shipment]
    @crates = hash[:crates]
    @money = hash[:money]
    @pilot = pilot_location[destination]
  end

  def pilot_location
    pilots = {
      "Earth" => "Fry",
      "Mars" => "Amy",
      "Uranus" => "Bender"
    }
    pilots.default = "Leela"
    pilots
  end
  
  def bonuscalc
    money * 0.1
  end

  def self.weekly_total(array) #determines the total weekly delivery
    array.inject(0){|sum,x| sum += x.money}
  end

  def self.pilotbonus(array,name) #determines the total bonus of the pilot
    array.inject(0){|sum,x| sum += x.bonus if x.pilot == name;sum}
  end

  def self.pilottrips(array,name) #determines the number of trips for pilot
    array.inject(0){|sum,x| sum += 1 if x.pilot == name;sum}
  end

  def self.byplanet(array,planet) #determines total amount of money by planet
    array.inject(0){|sum,x| sum += x.money if x.destination == planet;sum}
  end

  def self.bypilot(array,name) #determines the total amount of money by pilot
    array.inject(0){|sum,x| sum += x.money if x.pilot == name;sum}
  end

  def self.listmaker(array,item) #creates an array of the :item from the Delivery object
    array.collect{|x| x.send(item)}.uniq
  end

  def self.seldel(array,name) #selects entire delivery row by the pilot
    array.select{|x| x.pilot==name}
  end
end

dd = CSV.read("planet_express_logs.csv", header_converters: :symbol, converters: :numeric,  headers:true).map{|x| x.to_hash}.map{|x| Delivery.new(x)} #main delivery class object

planettable = Delivery.listmaker(dd,"destination").zip(Delivery.listmaker(dd,"destination").map{|a| Delivery.byplanet(dd,a)}).to_h #hash of planet and total money from each, used for planet summary table

pilots = Delivery.listmaker(dd,"pilot") #for pilot productivity table
trips = Delivery.listmaker(dd,"pilot").map{|a| Delivery.pilottrips(dd,a)} #for pilot productivity table
bonus = Delivery.listmaker(dd,"pilot").map{|a| Delivery.pilotbonus(dd,a)} #for pilot productivity table
pmoney = Delivery.listmaker(dd,"pilot").map{|a| Delivery.bypilot(dd,a)} #for pie chart

# pilottable = Delivery.listmaker(dd,"pilot").zip(Delivery.listmaker(dd,"pilot").map{|a| Delivery.pilottrips(dd,a)}).zip(Delivery.listmaker(dd,"pilot").map{|a| Delivery.pilotbonus(dd,a)}) #array of [pilots], [trips], and [bonus] money from each, could not get to work with erb due indexing issues


new_file = File.open("./deliveryreport.html", "w+")
new_file << ERB.new(File.read("index.html.erb")).result(binding)
new_file.close
