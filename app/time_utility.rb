class TimeUtility
  def self.format_time_from_seconds seconds
    Time.at(seconds).utc.strftime("%H:%M")
  end
end
