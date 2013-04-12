require './dms'

class AprsIsMessage
  attr_reader :parsed

  def initialize
    @parsed = {
      lat: DMS.new,
      long: DMS.new,
      comment: ''
    }
  end

  def [](name)
    @parsed[name]
  end

  def has? name
    ! @parsed[name].nil?
  end

  def self.parse line
    mess = self.new
    mess.parse line
    mess
  end

  def parse line
    initialize

    matched = line =~ /^([a-zA-Z0-9-]*)>([^,]*),([^:]*):(.*)$/

    return if matched.nil?
    @parsed[:from]     = $1
    @parsed[:to]       = $2
    @parsed[:route]    = $3
    @parsed[:raw_data] = $4

    parse_data @parsed[:raw_data]
  end

  # http://www.aprs.net/vm/DOS/PROTOCOL.HTM
  def parse_data data
    return if data.nil?
    character = data[0]

    case character
    when ';'  #object, p58
      semi data
    when '='
      equal data
    when '@'
      at data
    when '!'
      bang data
    when '_'
      underscore data
    when '$'
      dollar data
    end
  end

  # p57, object data
  def semi data
    @parsed[:type] = :object

    object_name = data[1..9]
    live = data[10] == '*'
    time = data[11..17]
    lat  = data[18..25]
    long = data[27..35]

    symbol_table = data[26]
    symbol_code = data[36]

    parse_time time
    parse_coords "#{lat}/#{long}"
    parse_data_extension data[37..-1]
  end

  def bang data
    # !4304.30N/08923.96W
    parse_coords data[1..18]
  end

  def equal data
    # =3911.69N/09437.49W_PHG5130XASTIR-Linux",
    parse_coords data[1..18]
    parse_data_extension data[18..-1]
  end

  def at data
    # @291651z5209.97N/00709.65W
    parse_time data[1..7]
    parse_coords data[8..25]
    parse_data_extension data[26..-1]
  end

  def dollar data
    # comments. may contain weather data?
  end

  def underscore data
    # weather data?
  end


  # TODO implement "position ambiguity"
  # p24 of APRS101.pdf
  # TODO implement "compressed coordinates"
  def parse_coords data
    # DDMM.hhX/DDDMM.hhX
    # 5209.97N/00709.65W
    # 3107.77N/12124.52E
    # 4820.32N/00809.24E
    # 7Z$?;7?p_r4b
    lat, long = data.upcase.split '/'
    return if lat.nil? || long.nil?
    return if lat.empty? || long.empty?

    lat_sign = lat[-1] == 'N' ? 1 : -1
    long_sign = long[-1] == 'E' ? 1 : -1

    @parsed[:lat].set( lat[0..1].to_f * lat_sign,   lat[2..-2].to_f)
    @parsed[:long].set(long[0..2].to_f * long_sign, long[3..-2].to_f)
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

    @parsed[:time] = Time.new(year, month, day, hours, min, 0, 0)
  end


  def parse_data_extension data
    return '' if data.nil? || data.empty?

    case
    when data[0] == '_'
      parse_data_extension data[1..-1]

    when data[0..6] =~ /^PHG[0-9.]{4}/
      @parsed[:power]       = data[3].to_i ** 2
      @parsed[:height]      = 10 * ( 2 ** data[4].to_i )
      @parsed[:gain]        = data[5].to_i
      @parsed[:directivity] = data[6].to_i * 45
      parse_data_extension data[6..-1]

    when data[0..2] == 'RNG'
    when data[0..2] == 'DFS'
    when data[0] == 'T' && data[4] == 'C'
    when data[3] == '/'
      @parsed[:course] = data[0..2].to_i
      @parsed[:speed]  = data[4..6].to_i
      parse_data_extension data[7..-1]

    when data[0..3] =~ /^c[0-9.]{3}/
      @parsed[:wind_direction] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^s[0-9.]{3}/
      @parsed[:wind_speed] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^g[0-9.]{3}/
      @parsed[:gust] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^t[0-9.]{3}/
      @parsed[:temperature] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^r[0-9.]{3}/
      @parsed[:hour_rain] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^p[0-9.]{3}/
      @parsed[:day_rain] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..3] =~ /^P[0-9.]{3}/
      @parsed[:todays_rain] = data[1..3].to_i
      parse_data_extension data[4..-1]

    when data[0..2] =~ /^h[0-9.]{2}/
      @parsed[:humidity] = data[1..2].to_i
      parse_data_extension data[3..-1]

    when data[0..5] =~ /^b[0-9.]{5}/
      @parsed[:barometer] = data[1..5].to_i
      parse_data_extension data[6..-1]

    else
      if data.strip.empty?
        ''
      else
        @parsed[:comment] += data[0]
        parse_data_extension data[1..-1]
      end
    end
  end

  def hour
    @parsed[:time].hour unless @parsed[:time].nil?
  end

  def min
    @parsed[:time].min unless @parsed[:time].nil?
  end
end
