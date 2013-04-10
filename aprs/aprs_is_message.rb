class AprsIsMessage
  attr_accessor :sender, :dest, :route, :raw_data

  def self.parse line
    mess = self.new
    mess.parse line
    mess
  end

  def parse line
    matched = line =~ /^([a-zA-Z0-9-]*)>([^,]*),([^:]*):(.*)$/

    return if matched.nil?
    self.sender   = $1
    self.dest     = $2
    self.route    = $3
    self.raw_data = $4

    parse_data
  end

  # http://www.aprs.net/vm/DOS/PROTOCOL.HTM
  def parse_data
    return if raw_data.nil?

    segments = raw_data.split(/(@|!|_|=)/)
                       .reject{|s| s.empty?}
                       .each_slice(2)
                       .map{|(a,b)| [a,b]}

    segments.each do |(type, message)|
      # puts "\t #{type} >> #{message}"
      case type
      when '='
        equal message
      when '@'
        at message
      when '!'
        bang message
      when '_'
        underscore message
      when '$'
        dollar message
      end
    end
  end

  def bang data
    # 4820.32N/00809.24E
  end

  def equal data
    # 3107.77N/12124.52E
    # Position data
    ns, ew = data.split('/')
    # puts "\t\t LAT: #{ns}"
    # puts "\t\t LON: #{ew}"
  end

  def at data
    # 291651z5209.97N/00709.65W
    data = data.downcase
    time_format = data[6]
    time = data[0..5]
    coords = data[7..-1]
    parse_coords coords
  end

  def dollar data
    # comments. may contain weather data?
  end

  def underscore data
    # weather data?
  end


  def parse_coords data
    # DDMM.hh
    # 5209.97N/00709.65W
    # 3107.77N/12124.52E
    # 4820.32N/00809.24E
    lat, lon = data.split '/'

    lat_sign = lat[-1] == 'N' ? 1 : -1
    lon_sign = lon[-1] == 'E' ? 1 : -1

    self.lat = lat.to_f * lat_sign
    self.lon = lon.to_f * lon_sign
  end

  def parse_time data
    # DDHHMMf
    # 291651z
    day   = data[0...2].to_i
    hours = data[2...4].to_i
    min   = data[4...6].to_i

    today_gmt = Time.now.utc
    today_day = today_gmt.day
    month = today_gmt.month
    year  = today_gmt.year

    # so, on a month boundary, we need to do some
    # special handling, incase the packet comes in
    # a day late or something.
    if day > today_day
      month -= 1
    end

    if month <= 0
      year -= 1
      month = 12
    end

    self.time = Time.new(
      year,
      month,
      day,
      hours,
      min,
      0,
      0
    )
  end
end
