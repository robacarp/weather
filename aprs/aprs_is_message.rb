class AprsIsMessage
  attr_accessor :sender, :dest, :route, :data

  def self.parse line
    return nil unless line =~ /^([A-Z0-9-]*)>([^,]*),([^:]*):(.*)$/

    mess = self.new
    mess.sender = $1
    mess.dest   = $2
    mess.route  = $3
    mess.data   = $4

    mess
  end
end
