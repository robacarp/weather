# encoding: UTF-8

class DMS
  attr_reader :degrees, :minutes, :seconds, :sign

  def set degrees, minutes = nil, seconds = nil
    @degrees = degrees
    @minutes = minutes
    @seconds = seconds

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
  end

  def to_s
    "#{degrees}º#{minutes}'#{seconds.round(4)}\""
  end
end
