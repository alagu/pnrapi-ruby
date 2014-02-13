class Status

  def self.fetch(pnr)
    return_object = {}
    rand_captcha = rand.to_s[2..6].to_i
    params = {'lccp_pnrno1' => pnr, 'submitpnr' => 'Get Status', 'lccp_cap_val' => rand_captcha, 'lccp_capinp_val' => rand_captcha} 
    headers = {"Content-type"    => "application/x-www-form-urlencoded",
               "Host"            => "www.indianrail.gov.in",
               "User-Agent"      => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1",
               "Accept"          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
               "Accept-Language" => "en-us,en;q=0.5",
               "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
               "Keep-Alive"      => "115",
               "Connection"      => "keep-alive",
               "Referer"         => "http://www.indianrail.gov.in/pnr_stat.html",
               "Accept"          => "text/plain"}

    require 'nokogiri'
    require 'open-uri'
    url  = Nokogiri::HTML(open("http://www.indianrail.gov.in/pnr_Enq.html")).css('form#form3')[0]['action']

    return_object = {}
    return_object['status'] = 'OK'
    return_object['data']   = {}
    date = ''

    begin
      response = RestClient.post url, params, headers
      contents = response.to_s.split("\n")

      statuslines = []
      contents.each do |line|
        if not line.index('border_both').nil? and not line.index('border_both').nil?
          statuslines.push line
        end
      end

      if statuslines.length == 0
        return_object['status'] = 'INVALID'
        return_object['data']   = {'pnr_number' => pnr , 'message' => 'Invalid number'}
      else
        expression = />(.*)</

        i = 0
        passenger_count = 0
        passenger_line  = -1
        chart_prepared = true

        statuslines.each do |line|
          matches = (expression.match line).to_a

          if matches.length > 0 
            statement = matches[1].gsub('<B>','').gsub('</B>','')
            statement.strip!

            if i == 0
              return_object['data']['train_number'] = statement.gsub('*','')      
            elsif i == 1
              return_object['data']['train_name'] = statement
            elsif i == 2 
              date = statement.gsub(' ','')
              timestamp = DateTime.strptime(date, "%d-%m-%Y").to_time.to_i
              return_object['data']['travel_date'] = {'timestamp' => timestamp, 'date' => date}
            elsif i == 3
              return_object['data']['from'] = Station.get_station(statement)
              return_object['data']['from']['time'] = Schedule.get_departure_time(return_object['data']['train_number'], return_object['data']['from'][:code])
            elsif i == 4
              return_object['data']['to'] = Station.get_station(statement)
              return_object['data']['to']['time'] =  Schedule.get_arrival_time(return_object['data']['train_number'], return_object['data']['to'][:code])
            elsif i == 5
              return_object['data']['alight'] = Station.get_station(statement)
              return_object['data']['alight']['time'] = Schedule.get_arrival_time(return_object['data']['train_number'], return_object['data']['to'][:code])
            elsif i == 6
              return_object['data']['board'] = Station.get_station(statement)
              return_object['data']['board']['time'] = Schedule.get_departure_time(return_object['data']['train_number'], return_object['data']['from'][:code])
              departure_string  = (date + " " + return_object['data']['board']['time'] + " +05:30")
              return_object['data']['board']['timestamp'] = DateTime.strptime(departure_string, "%d-%m-%Y %H:%M %z").to_time.to_i
            elsif i == 7
              return_object['data']['class'] = statement
            elsif i > 7
              if not statement.index('Passenger').nil?
                passenger_count = passenger_count + 1

                passenger_line = 0
                if passenger_count == 1
                  return_object['data']['passenger'] = [] 
                end
                return_object['data']['passenger'].push({'seat_number' => '', 'status' => ''})
              else
                if passenger_line == 0
                  return_object['data']['passenger'][passenger_count-1]['seat_number'] = statement.gsub('  ',' ')
                  passenger_line = passenger_line + 1
                elsif passenger_line == 1
                  return_object['data']['passenger'][passenger_count-1]['status'] = statement.gsub('  ',' ')
                  passenger_line = passenger_line + 1
                end
              end
            end

            if i>7 and not statement.index('CHART NOT PREPARED').nil?
              chart_prepared = false
            end

            return_object['data']['chart_prepared'] = chart_prepared
            return_object['data']['pnr_number'] = pnr

            i = i + 1
          end
        end         
      end
    rescue Exception => e
      return_object['status'] = 'TIMEOUT'
      return_object['data']   = {'pnr_number' => pnr , 'message' => e.to_s }
    end

    return return_object
  end
end
