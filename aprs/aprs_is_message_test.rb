require 'minitest/autorun'

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
    assert @aim.lat == 5209.97
    assert @aim.lon == -709.65

    @aim.parse_coords('5209.97S/00709.65E')
    assert @aim.lat == -5209.97
    assert @aim.lon == 709.65
  end
end