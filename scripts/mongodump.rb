require 'sqlite3'
require 'mongo'
require File.join(File.dirname(File.dirname(__FILE__)), 'app.rb')


@client = MongoClient.new('localhost', 27017)
@db     = @client['pnrapi']

def push_data

  db = SQLite3::Database.new "indian_railways.sqlite3"

  # Push stations
  @stations   = @db['stations']
  @stations.remove
  i = 0
  puts "Adding stations"
  db.execute( "select * from stations" ) do |row|
    code = row[1]
    name = row[2]
    @stations.insert({'code' => code, 'name' => name})
    i = i + 1
  end

  puts "Checking if #{i} entries are added to stations"
  puts "Entries = #{@stations.find({}).to_a.length}"


  # Push schedule
  @schedule = @db['schedule']
  @schedule.remove
  i = 0
  puts "Adding schedule"
  db.execute("select arrival, departure, train_number, station_code from schedule") do |row|
    arrival      = row[0]
    departure    = row[1]
    train_number = row[2]
    station_code = row[3]

    @schedule.insert({'arrival' => arrival, 
      'departure' => departure,
      'train_number' => train_number,
      'station_code' => station_code })
 
    i = i + 1 
  end

  puts "Checking if #{i} entries are added to stations"
  puts "Entries = #{@schedule.find({}).to_a.length}"
end

push_data()