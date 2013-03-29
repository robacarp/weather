class AprsIsMessage
  attr_accessor :sender, :dest, :route, :raw_data

  def self.parse line
    matched = line =~ /^([a-zA-Z0-9-]*)>([^,]*),([^:]*):(.*)$/

    return if matched.nil?

    mess = self.new
    mess.sender = $1
    mess.dest   = $2
    mess.route  = $3
    mess.raw_data   = $4

    mess.parse_data

    mess
  end

  # http://www.aprs.net/vm/DOS/PROTOCOL.HTM
  def parse_data
    return if raw_data.nil?
    type = raw_data[0]
    message = raw_data[1..-1]


    case type
    when '='
      equal message
    when '!'
      bang message
    when '@'
      at message
    when '_'
      underscore message
    end

  end

  def bang data
  end

  def equal data
  end

  def at data
  end

  def star data
  end

  def underscore data
  end

end
