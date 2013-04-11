# encoding: UTF-8

class DMS
  attr_reader :minutes, :seconds, :negative

  def set degrees, minutes = nil, seconds = nil
    @degrees = degrees
    @minutes = minutes
    @seconds = seconds

    @negative = @degrees < 0
    @degrees  = @degrees.abs

    unless @degrees == @degrees.round
      @degrees = degrees.truncate
      f_part = degrees - @degrees
      @minutes = f_part * 60
    end

    unless @minutes == @minutes.round
      f_part = @minutes - @minutes.truncate
      @minutes = @minutes.truncate
      @seconds = f_part * 60
    end

    @minutes = @minutes.abs
    @seconds = @seconds.abs
  end

  def degrees
    multiple = negative ? -1 : 1
    (@degrees || 0) * multiple
  end

  def to_s
    "#{degrees}º#{minutes}'#{(seconds || 0).round(4)}\""
  end
end
