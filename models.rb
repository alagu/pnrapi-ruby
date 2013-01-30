class Status

  def self.fetch(pnr)
    return_object = {}
    params = {'lccp_pnrno1' => pnr, 'submitpnr' => 'Get Status'}
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

    url  = 'www.indianrail.gov.in/cgi_bin/inet_pnrstat_cgi.cgi'

    return_object = {}
    return_object['status'] = 'OK'
    return_object['data']   = { 'lines' => []}

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
        return_object['debug'] = statuslines
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
            return_object['data']['lines'].push statement

            if i == 0
              return_object['data']['train_number'] = statement.gsub('*','')      
            elsif i == 1
              return_object['data']['train_name'] = statement
            elsif i == 2 
              date = statement.gsub(' ','')
              timestamp = DateTime.strptime(date, "%d-%m-%Y").to_time.to_i
              return_object['data']['travel_date'] = {'timestamp' => timestamp, 'date' => date}
            elsif i == 3
              return_object['data']['from'] = {:code => statement, :name => statement} #DB restapi.models.Station().get_station(code=statement)
              return_object['data']['from']['time'] = statement # DB restapi.models.Schedule().get_departure_time(return_object['data']['train_number'], return_object['data']['from']['code'])
            elsif i == 4
              return_object['data']['to'] = {:code => statement, :name => statement} #DB restapi.models.Station().get_station(code=statement)
              return_object['data']['to']['time'] = statement # DB restapi.models.Schedule().get_departure_time(return_object['data']['train_number'], return_object['data']['from']['code'])
            elsif i == 5
              return_object['data']['alight'] = {:code => statement, :name => statement} #DB restapi.models.Station().get_station(code=statement)
              return_object['data']['alight']['time'] = statement # DB restapi.models.Schedule().get_departure_time(return_object['data']['train_number'], return_object['data']['from']['code'])
            elsif i == 6
              return_object['data']['board'] = {:code => statement, :name => statement} #DB restapi.models.Station().get_station(code=statement)
              return_object['data']['board']['time'] = statement # DB restapi.models.Schedule().get_departure_time(return_object['data']['train_number'], return_object['data']['from']['code'])
            elsif i == 7
              return_object['data']['class'] = statement
            elsif i > 7
              puts statement
              if not statement.index('Passenger').nil?
                passenger_count = passenger_count + 1
                passenger_line = 0
                if passenger_count == 1
                  return_object['data']['passenger'] = [] 
                end
#                return_object['data']['passenger'].push({'seat_number' => '', 'status' => ''})
              end
            end
            i = i + 1
          end
        end         
      end
    rescue

    end


    
    return return_object

  end

=begin
  try :
    
          elif(i==4):
            return_object['data']['to'] = restapi.models.Station().get_station(code=statement)
            return_object['data']['to']['time'] = restapi.models.Schedule().get_arrival_time(return_object['data']['train_number'], return_object['data']['to']['code'])
          elif(i==5):
            return_object['data']['alight'] = restapi.models.Station().get_station(code=statement)
            return_object['data']['alight']['time'] = restapi.models.Schedule().get_arrival_time(return_object['data']['train_number'], return_object['data']['alight']['code'])
          elif(i==6):
            return_object['data']['board'] = restapi.models.Station().get_station(code=statement)
            return_object['data']['board']['time'] = restapi.models.Schedule().get_departure_time(return_object['data']['train_number'], return_object['data']['board']['code'])
            departure_string  = (date + " " + return_object['data']['board']['time'])
            departure_date = time.strptime(departure_string, "%d-%m-%Y %H:%M")
            return_object['data']['board']['timestamp'] = int(time.mktime(time.strptime(departure_string, "%d-%m-%Y %H:%M")))
          elif(i==7):
            return_object['data']['class'] = statement
          elif(i>7):
            if statement.find('Passenger') != -1:
              passenger_count = passenger_count + 1
              passenger_line = 0
              if (passenger_count == 1):
                return_object['data']['passenger'] = [] 
              return_object['data']['passenger'].append({'seat_number':'','status':''})
              continue
            else:
              if passenger_line == 0:
                return_object['data']['passenger'][passenger_count-1]['seat_number'] = statement.replace('  ',' ')
                passenger_line = passenger_line + 1
              elif passenger_line == 1:
                return_object['data']['passenger'][passenger_count-1]['status'] = statement.replace('  ',' ')
                passenger_line = passenger_line + 1
            
            if i>7 and statement.find('CHART NOT PREPARED') != -1:
              chart_prepared = False

          i=i+1
          
    return_object['data']['chart_prepared'] = chart_prepared
    return_object['data']['pnr_number'] = pnr_num
  except Exception as inst:
    return_object['status'] = 'TIMEOUT'
    return_object['data']   = {'pnr_number' : pnr_num , 'message' : '[' + str(inst) + '] ' +  inst.message}
    logging.debug('TIMEOUT ' + pnr_num)
    
  
  return return_object

    return {:hello => 'hi'}
  end

=end
end