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
    assert_equal 52,   @aim.lat.degrees
    assert_equal 9,    @aim.lat.minutes
    assert 58.2 - @aim.lat.seconds < 0.0001

    assert_equal -7,   @aim.long.degrees
    assert_equal -9,   @aim.long.minutes
    assert -39 - @aim.long.seconds < 0.0001

    @aim.parse_coords('5209.97S/00709.65E')
    assert_equal -52,   @aim.lat.degrees
    assert_equal -9,    @aim.lat.minutes
    assert -58.2 - @aim.lat.seconds < 0.0001

    assert_equal 7,     @aim.long.degrees
    assert_equal 9,     @aim.long.minutes
    assert 39 - @aim.long.seconds < 0.0001
  end

  def test_parsing_messages
    @test_cases = Crack::JSON.parse( File.read( 'test_data.json' ) )

    @test_cases.each do |data|
      @aim.parse data['string']

      puts "data : #{@aim.raw_data}"
      puts "route: #{@aim.route}"
      puts "from : #{@aim.from}"
      puts "to   : #{@aim.to}"
      puts "lat  : #{@aim.lat}"
      puts "long : #{@aim.long}"
      puts "hour : #{@aim.hour}"

      assert_equal data['route'], @aim.route, "route should be #{data['route']}, instead got #{@aim.route}"
      assert_equal data['from'],  @aim.from,  "from should be #{data['from']}, instead got #{@aim.from}"
      assert_equal data['to'],    @aim.to,    "to should be #{data['to']}, instead got #{@aim.to}"
      assert_equal data['hour'],  @aim.hour, "Hour should be #{data['hour']}, instead got #{@aim.hour}"

      puts "\n"
    end
  end

end
