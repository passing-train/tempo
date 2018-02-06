class PrefsWindowController < NSWindowController

  def layout
    @layout ||= PrefsWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @button_close = @layout.get(:button_close)
      @button_close.target = self
      @button_close.action = 'closeWindow:'

      @time_interval = @layout.get(:time_interval)
      @time_interval.delegate = self

      @check_vary_interval = @layout.get(:check_vary_interval)
      @check_vary_interval.target = self
      @check_vary_interval.action = 'check_vary_interval_update:'
      if NSUserDefaults.standardUserDefaults.boolForKey('VaryInterval')
        @check_vary_interval.setState NSOnState
      else
        @check_vary_interval.setState NSOffState
      end

    end
  end

  def closeWindow(sender)
    window.close
  end

  def check_vary_interval_update notification
    if @check_vary_interval.state == NSOnState
      NSUserDefaults.standardUserDefaults.setObject(true,forKey:'VaryInterval')
    else
      NSUserDefaults.standardUserDefaults.setObject(false,forKey:'VaryInterval')
    end

  end

  def controlTextDidChange(notification)
    textField = notification.object
    if textField.tag == 1
      NSUserDefaults.standardUserDefaults.setObject(textField.stringValue,forKey:'AskInterval')
    end
  end

end
