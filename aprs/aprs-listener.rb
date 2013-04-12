require 'socket'
require './aprs_is_message'

def parse_line line
  return if line[0] == '#'
  puts "PACKET: #{line}"

  begin
    @aim = AprsIsMessage.parse line
  rescue Exception => e
    puts "\033[31mMessage Parsing failed\033[0m: #{e.message}"
    return
  end

  return if @aim.nil?

  puts "from: "  + @aim[:from]
  puts "to: "    + @aim[:to]
  puts "route: " + @aim[:route]

  puts "lat: "  + @aim[:lat].to_s
  puts "long: "  + @aim[:long].to_s

  puts "time: "  + @aim.hour.to_s + ':' + @aim.min.to_s if @aim.has? :time

  puts "course: "      + @aim[:course].to_s        if @aim.has? :course
  puts "speed: "       + @aim[:speed].to_s         if @aim.has? :speed

  puts "power: "       + @aim[:power].to_s         if @aim.has? :power
  puts "height: "      + @aim[:height].to_s        if @aim.has? :height
  puts "gain: "        + @aim[:gain].to_s          if @aim.has? :gain
  puts "directivity: " + @aim[:directivity].to_s   if @aim.has? :directivity

  puts "temperature: " + @aim[:temperature].to_s   if @aim.has? :temperature
  puts "hour_rain: "   + @aim[:hour_rain].to_s     if @aim.has? :hour_rain
  puts "day_rain: "    + @aim[:day_rain].to_s      if @aim.has? :day_rain
  puts "todays_rain: " + @aim[:todays_rain].to_s   if @aim.has? :todays_rain
  puts "humidity: "    + @aim[:humidity].to_s      if @aim.has? :humidity
  puts "barometer: "   + @aim[:barometer].to_s     if @aim.has? :barometer
  puts "\n-----------\ncomment: "     + @aim[:comment]            unless @aim[:comment].empty?
  puts "\n-----------"
end

if false
  File.open('data-log.txt','r') do |historical_data|
    until historical_data.eof?
      parse_line historical_data.readline
    end
  end


  exit


else
  puts 'Connecting...'
  aprs = TCPSocket.new 'noam.aprs2.net', 14580
  logfile = File.open('data-log.txt', 'w+')
  puts 'connected, requesting filter...'

  aprs.puts 'user KD0PNR-A0 pass -1 filter t/w'

  while line = aprs.gets
    logfile.puts line
    logfile.flush
    parse_line line
  end

  logfile.close
  aprs.close


end
