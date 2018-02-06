class TimeUtility
  def self.format_time_from_seconds seconds
    Time.at(seconds).utc.strftime("%H:%M")
  end

  def self.format_time_from_seconds_to_metric_hours seconds
    hours = 0.0
    if seconds > 0
      hours = seconds.to_f / 60.0 / 60.0
      hours.round 2
    else
      0.0
    end
  end

  def self.format_time_from_metric_hours_to_seconds metric
    if metric > 0
      seconds = metric.to_f * 60.0 * 60.0
      seconds.to_i
    else
      0
    end
  end

end
