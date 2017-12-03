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

      @task_label = @layout.get(:task_title_label)

      @task_text_field = @layout.get(:task_title)
      @task_text_field.tableViewDelegate = @parent
      @task_text_field.delegate = @parent

      self.window.setInitialFirstResponder(@task_text_field)
      self.window.makeFirstResponder(@task_text_field)

      @button_ok = @layout.get(:button_ok)
      @button_ok.target = self
      @button_ok.action = 'verify_popover:'

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

  def verify_popover sender
    unless @task_text_field.autoCompletePopover.isShown
      write_and_close_window sender
    end
  end

  def write_and_close_window(sender)
    @parent.set_new_answer(@task_text_field.stringValue)
    close_window sender
  end

  def close_window(sender)
    NSApp.delegate.set_menu_bar_normal
    window.close
  end

end
