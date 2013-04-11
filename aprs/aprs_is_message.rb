require './dms'

class AprsIsMessage
  attr_reader :from, :to, :route, :raw_data, :lat, :long, :time

  def self.parse line
    mess = self.new
    mess.parse line
    mess
  end

  def parse line
    @from =
      @to =
      @route =
      @raw_data =
      @lat =
      @long =
      @time =
        nil

    matched = line =~ /^([a-zA-Z0-9-]*)>([^,]*),([^:]*):(.*)$/

    return if matched.nil?
    @from     = $1
    @to       = $2
    @route    = $3
    @raw_data = $4

    parse_data
  end

  # http://www.aprs.net/vm/DOS/PROTOCOL.HTM
  def parse_data
    return if raw_data.nil?
    character = raw_data[0]

    case character
    when ';'  #object, p58
      semi raw_data
    when '='
      equal raw_data
    when '@'
      at raw_data
    when '!'
      bang raw_data
    when '_'
      underscore raw_data
    when '$'
      dollar raw_data
    end
  end

  def semi data
    object_name = data[1..9]
    live = data[10] == '*'
    time = data[11..17]
    lat  = data[18..25]
    long = data[27..35]

    symbol_table = data[26]
    symbol_code = data[36]
    data = data[37..43]
    comment = data[44..-1]

    parse_coords "#{lat}/#{long}"
    parse_time time

    # puts object_name, live, time, lat, long, symbol_code, data, comment
  end

  def bang data
    coords = data[1..18]
    parse_coords coords
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
    time = data[1..7]
    coords = data[8..25]
    parse_time time
    parse_coords coords

    # puts @unparsed, time, coords
  end

  def dollar data
    # comments. may contain weather data?
  end

  def underscore data
    # weather data?
  end


  # TODO implement "position ambiguity"
  # p24 of APRS101.pdf
  def parse_coords data
    # DDMM.hhX/DDDMM.hhX
    # 5209.97N/00709.65W
    # 3107.77N/12124.52E
    # 4820.32N/00809.24E
    lat, long = data.upcase.split '/'

    lat_sign = lat[-1] == 'N' ? 1 : -1
    long_sign = long[-1] == 'E' ? 1 : -1

    @lat = DMS.new
    @long = DMS.new

    @lat.set lat[0..1].to_f * lat_sign, lat[2..-2].to_f
    @long.set long[0..2].to_f * long_sign, long[3..-2].to_f
  end

  # TODO implement different time formats:
  # p22 of APRS101.pdf
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

    if day < 1
      day = 1
    end

    if month <= 0
      year -= 1
      month = 12
    end

    hours = 0 if hours > 23 || hours < 0
    min   = 0 if min   > 59 || min   < 0

    @time = Time.new(
      year,
      month,
      day,
      hours,
      min,
      0,
      0
    )
  end

  def hour
    @time.hour unless @time.nil?
  end

  def min
    @time.min unless @time.nil?
  end
end
