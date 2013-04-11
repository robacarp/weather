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

    assert_equal @aim[:time].hour, 16
    assert_equal @aim[:time].day, 29
    assert_equal @aim[:time].min, 51
  end

  def test_coordinate_parser
    @aim.parse_coords('5209.97N/00709.65W')
    assert_equal 52,   @aim[:lat].degrees, "degrees should be 52, instead got #{@aim[:lat].degrees}"
    assert_equal 9,    @aim[:lat].minutes, "minutes should be  9, instead got #{@aim[:lat].minutes}"
    assert 58.2 - @aim[:lat].seconds < 0.0001

    assert_equal -7,   @aim[:long].degrees, "degrees should be -7, instead got #{@aim[:long].degrees}"
    assert_equal 9,   @aim[:long].minutes, "minutes should be 9, instead got #{@aim[:long].minutes}"
    assert 39 - @aim[:long].seconds < 0.0001

    @aim.parse_coords('5209.97S/00809.65E')
    assert_equal -52,   @aim[:lat].degrees
    assert_equal 9,    @aim[:lat].minutes
    assert 58.2 - @aim[:lat].seconds < 0.0001

    assert_equal 8,     @aim[:long].degrees
    assert_equal 9,     @aim[:long].minutes
    assert 39 - @aim[:long].seconds < 0.0001
  end

  @test_cases = Crack::JSON.parse( File.read( 'test_data.json' ) )

  @test_cases.each_with_index do |data,i|
    next if data['test'] == false

    define_method("test_data_#{i}") {
      @aim.parse data['string']

      if data['debug']
        puts "\n"
        @aim.parsed.each do |(k,v)|
          puts "#{k}: #{v}"
        end
        puts "\n"
      end

      assert_equal data['route'], @aim[:route]
      assert_equal data['from'],  @aim[:from]
      assert_equal data['to'],    @aim[:to]

      unless data['lat'].nil?
        assert_in_delta data['lat'][0], @aim[:lat].degrees
        assert_in_delta data['lat'][1], @aim[:lat].minutes
        assert_in_delta data['lat'][2], @aim[:lat].seconds
      end

      unless data['long'].nil?
        assert_in_delta data['long'][0], @aim[:long].degrees
        assert_in_delta data['long'][1], @aim[:long].minutes
        assert_in_delta data['long'][2], @aim[:long].seconds
      end

      assert_equal data['hour'], @aim.hour
      assert_equal data['min'],  @aim.min

      assert_equal data['course'], @aim[:course]
      assert_equal data['speed'],  @aim[:speed]

      assert_equal data['power'],       @aim[:power]
      assert_equal data['height'],      @aim[:height]
      assert_equal data['gain'],        @aim[:gain]
      assert_equal data['directivity'], @aim[:directivity]

      assert_equal data['temperature'], @aim[:temperature]
      assert_equal data['hour_rain'],   @aim[:hour_rain]
      assert_equal data['day_rain'],    @aim[:day_rain]
      assert_equal data['todays_rain'], @aim[:todays_rain]
      assert_equal data['humidity'],    @aim[:humidity]
      assert_equal data['barometer'],   @aim[:barometer]
    }
  end

end
