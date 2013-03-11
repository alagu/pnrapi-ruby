require 'mixpanel'

class StatsJob
  @queue = :stats

  def self.perform(name, properties)
     @mixpanel = Mixpanel::Tracker.new "f5d7e2a1a08792fe68d1d833b54fb303"
     @mixpanel.track name, properties
     puts "Done #{name}, #{properties.to_s}"
  end
end
