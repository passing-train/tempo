class AskWindowController < NSWindowController

  def layout
    @layout ||= AskWindowLayout.new
  end

  def init_with_arguments(parent, prompt, default_answer)
    @parent = parent
    @prompt = prompt
    @default_answer = default_answer
    init
  end

  def init
    super.tap do
      self.window = layout.window

      @task_text_field = @layout.get(:task_title)
      @task_text_field.setStringValue @default_answer

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
    @parent.set_new_answer(@task_text_field.stringValue)
    window.close
  end

end
