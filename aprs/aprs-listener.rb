require 'socket'
require './aprs_is_message'

test_messages = [
    "VE3EP>WIDE2-1,qAS,VA3JLF-1:@282328z4354.89N/07711.21W_296/004g006t039r000p000P000h36b10190>East Lake Report (ve3ep@rac.ca) {UIV32N}",
    "KC5EVE-14>APU25N,TCPIP*,qAS,KC5EVE-13:@282328z3735.90N/10748.65W_231/005g006t063r000p000P000h16b10215/ {UIV32N}"
]

test_messages.each do |m|
  AprsIsMessage.parse m
end



puts 'Connecting...'
aprs = TCPSocket.new 'noam.aprs2.net', 14580
logfile = File.open('data-log.txt', 'w+')
puts 'connected, requesting filter...'

aprs.puts 'user KD0PNR-A0 pass -1 filter t/w'

while line = aprs.gets
  logfile.puts line
  logfile.flush

  message = AprsIsMessage.parse line
  next if message.nil?

  puts "SENDER: \033[31m#{message.sender}\033[0m"
  puts "DEST  : \033[33m#{message.dest}\033[0m"
  puts "PATH  : \033[37m#{message.route}\033[0m"
  puts "DATA  : #{message.data}"
  puts "PACKET: #{line}"
  puts "\n-----------"
end

aprs.close

