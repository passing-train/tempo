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
    end
  end

  def closeWindow(sender)
    window.close
  end

  def controlTextDidChange(notification)
    textField = notification.object
    if textField.tag == 1
      NSUserDefaults.standardUserDefaults.setObject(textField.stringValue,forKey:'AskInterval')
    end
  end

end
