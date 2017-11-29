class AskWindowController < NSWindowController

  def layout
    @layout ||= AskWindowLayout.new
  end

  def init_with_arguments(parent)
    @parent = parent
    init
  end

  def init
    super.tap do
      self.window = layout.window

      @task_text_field = @layout.get(:task_title)
      @task_label = @layout.get(:task_title_label)

      @button_ok = @layout.get(:button_ok)
      @button_ok.target = self
      @button_ok.action = 'write_and_close_window:'

      @button_cancel = @layout.get(:button_cancel)
      @button_cancel.target = self
      @button_cancel.action = 'close_window:'
    end
  end

  def set_default_value default_answer
    @task_text_field.setStringValue default_answer
  end

  def set_prompt prompt
    boldFontName = NSFont.boldSystemFontOfSize(13.0)
    str = NSMutableAttributedString.alloc.initWithString(prompt)
    str.addAttribute(NSFontAttributeName, value:boldFontName, range:NSMakeRange(0, str.length))
    @task_label.setAttributedStringValue str
  end

  def close_window(sender)
    window.close
  end

  def write_and_close_window(sender)
    @parent.set_new_answer(@task_text_field.stringValue)
    window.close
  end

end
