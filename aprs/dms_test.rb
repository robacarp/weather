require 'minitest/autorun'
require 'debugger'

require './dms'

class DMSTest < MiniTest::Unit::TestCase
  def setup
    @dms = DMS.new
  end

  def test_takes_fractional_degree
    @dms.set 39.707187

    assert_equal 39, @dms.degrees
    assert_equal 42, @dms.minutes
    assert_equal 25.8732, @dms.seconds.round(4)
  end

  def test_takes_fractional_minute
    @dms.set 49, 3.5

    assert_equal 49, @dms.degrees
    assert_equal 3,  @dms.minutes
    assert_equal 30, @dms.seconds
  end

  def test_takes_no_fractions
    @dms.set 12,23,45

    assert_equal 12, @dms.degrees
    assert_equal 23,  @dms.minutes
    assert_equal 45, @dms.seconds
  end

  def test_carry_the_negative
    @dms.set -39.707187
    assert_equal -39, @dms.degrees
    assert_equal -42, @dms.minutes
    assert_equal -25.8732, @dms.seconds.round(4)
  end
end
