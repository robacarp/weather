require 'minitest/autorun'
require 'crack/json'
require 'debugger'

require './aprs_is_message'

class AprsIsMessageTest < MiniTest::Unit::TestCase
  def setup
    @aim = AprsIsMessage.new
  end

  def test_time_parser
    @aim.parse_time('291651z')

    assert_equal @aim.time.hour, 16
    assert_equal @aim.time.day, 29
    assert_equal @aim.time.min, 51
  end

  def test_coordinate_parser
    @aim.parse_coords('5209.97N/00709.65W')
    assert_equal 52,   @aim.lat.degrees, "degrees should be 52, instead got #{@aim.lat.degrees}"
    assert_equal 9,    @aim.lat.minutes, "minutes should be  9, instead got #{@aim.lat.minutes}"
    assert 58.2 - @aim.lat.seconds < 0.0001

    assert_equal -7,   @aim.long.degrees, "degrees should be -7, instead got #{@aim.long.degrees}"
    assert_equal 9,   @aim.long.minutes, "minutes should be 9, instead got #{@aim.long.minutes}"
    assert 39 - @aim.long.seconds < 0.0001

    @aim.parse_coords('5209.97S/00709.65E')
    assert_equal -52,   @aim.lat.degrees
    assert_equal 9,    @aim.lat.minutes
    assert 58.2 - @aim.lat.seconds < 0.0001

    assert_equal 7,     @aim.long.degrees
    assert_equal 9,     @aim.long.minutes
    assert 39 - @aim.long.seconds < 0.0001
  end

  @test_cases = Crack::JSON.parse( File.read( 'test_data.json' ) )

  @test_cases.each_with_index do |data,i|
    next if data['test'] == false

    define_method("test_data_#{i}") {
      @aim.parse data['string']

      puts "data : #{@aim.raw_data}"
      puts "route: #{@aim.route}"
      puts "from : #{@aim.from}"
      puts "to   : #{@aim.to}"
      puts "lat  : #{@aim.lat}"
      puts "long : #{@aim.long}"
      puts "hour : #{@aim.hour}"
      puts "min  : #{@aim.min}"

      assert_equal data['route'], @aim.route, "route should be #{data['route']}, instead got #{@aim.route}"
      assert_equal data['from'],  @aim.from,  "from should be #{data['from']}, instead got #{@aim.from}"
      assert_equal data['to'],    @aim.to,    "to should be #{data['to']}, instead got #{@aim.to}"

      assert_in_delta data['lat'][0], @aim.lat.degrees
      assert_in_delta data['lat'][1], @aim.lat.minutes
      assert_in_delta data['lat'][2], @aim.lat.seconds

      assert_in_delta data['long'][0], @aim.long.degrees
      assert_in_delta data['long'][1], @aim.long.minutes
      assert_in_delta data['long'][2], @aim.long.seconds

      assert_equal data['hour'], @aim.hour, "Hour should be #{data['hour']}, instead got #{@aim.hour}"
      assert_equal data['min'],  @aim.min,  "Minute should be #{data['min']}, instead got #{@aim.min}"

      puts "\n"
    }
  end

end
