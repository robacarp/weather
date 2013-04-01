require 'socket'
require './aprs_is_message'

def parse_line line
  puts "PACKET: #{line}"
  message = AprsIsMessage.parse line
  return if message.nil?

  puts "SENDER  : \033[31m#{message.sender}\033[0m"
  puts "DEST    : \033[33m#{message.dest}\033[0m"
  puts "PATH    : \033[37m#{message.route}\033[0m"
  puts "DATA    : #{message.raw_data}"
  puts "TIME    : #{message.time}"
  puts "LAT/LON : #{message.lat}/#{message.lon}"
  puts "\n-----------"
end

if true
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
