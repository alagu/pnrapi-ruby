include Mongo

class Station
  def self.get_station(code)
    begin
      stations = DB['stations']
      station  = stations.find({:code => code}).to_a

      station = station[0]
      {:code => code.upcase, :name => station['name'].upcase}
    rescue Exception => e
      {:code => code.upcase, :name => code.upcase, :error => e.to_s}
    end
  end
end

class Schedule
  def self.get_departure_time(train, station)
    begin
      schedule_db = DB['schedule']
      schedule = schedule_db.find({:train_number => train.to_s, :station_code => station.to_s}).to_a
      schedule = schedule[0]

      if schedule['departure'].empty?
        return "00:00"
      else
        return schedule['departure']
      end
    rescue Exception => e
      "00:00"
    end
  end

  def self.get_arrival_time(train, station)
    begin
      schedule_db = DB['schedule']
      schedule = schedule_db.find({:train_number => train.to_s, :station_code => station.to_s}).to_a
      schedule = schedule[0]

      if schedule['arrival'].empty?
        return "00:00"
      else
        return schedule['arrival']
      end
    rescue Exception => e
      "00:00"
    end
  end
end