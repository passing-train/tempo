class AskWindowController < NSWindowController

  include CDQ

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
      @task_text_field.tableViewDelegate = self
      @task_text_field.myDelegate = self

      @customer_field = @layout.get(:customer_field)
      @project_field = @layout.get(:project_field)
      @time_today_field = @layout.get(:time_today_field)
      @total_time_field = @layout.get(:total_time_field)

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

  ##DELEGATE METHOD tableViewDelegate Task Text Field
  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)
    matches = Entry.where(:title).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:title).uniq
    matches
  end

  def set_default_value default_answer
    @task_text_field.setStringValue default_answer
  end

  def didClickedCloseKey
    set_task_meta_info
  end

  def set_prompt prompt
    boldFontName = NSFont.boldSystemFontOfSize(13.0)
    str = NSMutableAttributedString.alloc.initWithString(prompt)
    str.addAttribute(NSFontAttributeName, value:boldFontName, range:NSMakeRange(0, str.length))
    @task_label.setAttributedStringValue str
  end

  #get record and attributes
  def set_task_meta_info answer=''

    if answer==''
      answer = @task_text_field.stringValue
    end

    existing_entry = Entry.where(:title).eq(answer).sort_by('created_at').last

    if existing_entry
      @project_field.setStringValue existing_entry.project_id if existing_entry.project_id
      @customer_field.setStringValue existing_entry.customer_name
      @time_today_field.setStringValue existing_entry.time_today
      @total_time_field.setStringValue existing_entry.total_time
    else
      @project_field.setStringValue ''
      @customer_field.setStringValue ''
      @time_today_field.setStringValue ''
      @total_time_field.setStringValue ''
    end
  end

  def verify_popover sender
    unless @task_text_field.autoCompletePopover.isShown
      write_and_close_window sender
    end
  end

  def write_and_close_window(sender)
    @parent.set_new_answer(@task_text_field.stringValue)
    NSApp.delegate.reload_all_windows
    close_window sender
  end

  def close_window(sender)
    NSApp.delegate.set_menu_bar_normal
    window.close
  end

end
