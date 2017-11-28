class AskWindowController < NSWindowController

  def layout
    @layout ||= AskWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @task_text_field = @layout.get(:task_title)

      @button_ok = @layout.get(:button_ok)
      @button_ok.target = self
      @button_ok.action = 'write_and_close_window:'

      @button_cancel = @layout.get(:button_cancel)
      @button_cancel.target = self
      @button_cancel.action = 'close_window:'

    end
  end

  def close_window(sender)
    window.close
  end

  def write_and_close_window(sender)
    NSLog(@task_text_field.stringValue)
    window.close
  end

end
