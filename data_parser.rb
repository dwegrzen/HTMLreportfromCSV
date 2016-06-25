require 'erb'
require 'csv'

hashdata = CSV.read("planet_express_logs.csv", header_converters: :symbol, converters: :numeric,  headers:true).map{|x| x.to_hash}


class Delivery
  attr_accessor :destination, :shipment, :crates, :money, :pilot, :bonus, :net

  def initialize(hash)
    @destination = hash[:destination]
    @shipment = hash[:shipment]
    @crates = hash[:crates]
    @money = hash[:money]
    findpilot
    bonuscalc
    netcalc
  end

  def findpilot
    if destination == "Earth"
      self.pilot = "Fry"
    elsif destination == "Mars"
      self.pilot = "Amy"
    elsif destination == "Uranus"
      self.pilot = "Bender"
    else
      self.pilot = "Leela"
    end
  end

  def bonuscalc
    self.bonus = money * 0.1
  end

  def netcalc
    self.net = money - bonus
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
#collecting data to variables for ERB recall

planmon = planets.map{|a| dd.inject(0){|sum,y| sum =+ y.money if y.destination==a ;sum}}
combine = planets.zip(planets.map{|a| dd.inject(0){|sum,y| sum =+ y.money if y.destination==a ;sum}}) #takes planet list and combines with money by planet

planetmon = Delivery.listmaker(dd,"destination").zip(Delivery.listmaker(dd,"destination").map{|a| Delivery.byplanet(dd,a)}) #array of planet and total money from each




# pilotlist.each do |p|
#    pilotbonus<<(dd.inject(0){|sum,y| sum =+ y.bonus if y.pilot==p ;sum})
#  end


# dd = CSV.read("planet_express_logs.csv", header_converters: :symbol, converters: :numeric,  headers:true).map{|x| x.to_hash}.map{|x| Delivery.new(x)}


# dd = hashdata.map{|x| Delivery.new(x)}
