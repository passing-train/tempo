class Ask

  include CDQ

  PROMPTS = ["What\'re you working on?",
             "What\'cha up to?",
             "What\'s going on?",
             "How goes it?",
             "What\'s the plan?",
             "Where are you at?",
             "What\'s next?",
             "What\'ve you been up to?",
             "Status:",
             "Anything I can help with?",
             "What\'s happening?",
             "What\'s on your mind?"]
  def init
    reset_last
    self
  end

  def reset_last
    @last_answer = ''
    @last_time = nil
  end

  def ask_early
    if @timer
      @timer.fire
    end
  end

  def ask_and_schedule

    NSApp.delegate.set_menu_bar_active

    old_app = NSWorkspace.sharedWorkspace.frontmostApplication

    NSRunningApplication.currentApplication.activateWithOptions(NSApplicationActivateIgnoringOtherApps)

    @timer = nil

    begin

      ask

    rescue => e
      NSLog("Error %@", e)
      alert = NSAlert.alertWithMessageText('Problem asking for input: ' + e.message, defaultButton: "OK", alternateButton: nil, otherButton: nil, informativeTextWithFormat: "")
      alert.runModal
    end

    interval = NSUserDefaults.standardUserDefaults.integerForKey('AskInterval')

    # -5..5 + 20 yields a range of 15-25 minutes.
    wait_time = (((rand*10).to_i-5)+interval)*60
    @timer = NSTimer.scheduledTimerWithTimeInterval(wait_time, target: self, selector: 'ask_and_schedule', userInfo: nil, repeats: false)
    old_app.activateWithOptions(NSApplicationActivateIgnoringOtherApps)
  end

  def ask
    picked = PROMPTS[rand*PROMPTS.length]
    input_window(picked, @last_answer)
  end

  def set_new_answer(answer)
    if answer
      @last_answer = answer
      log(@last_answer)
    end
  end

  def input_window(prompt, default_value="")
    @ask_window_controller ||= AskWindowController.alloc.init_with_arguments(self)
    @ask_window_controller.set_prompt prompt
    @ask_window_controller.set_default_value default_value
    @ask_window_controller.showWindow(self)
    @ask_window_controller.window.orderFrontRegardless
  end

  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)
    matches = Entry.where(:title).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:title).uniq
    matches
  end

  def log(msg)

    if @last_time

      last_entry =  Entry.last
      now = NSDate::date

      distanceBetweenDates = now.timeIntervalSinceDate(last_entry.created_at)

      last_entry.time_delta = distanceBetweenDates.to_i

      if msg == last_entry.title
        last_entry.last_in_block = 0
      end

      cdq.save
    end


    Entry.create(title: msg)
    cdq.save

    @last_time = NSDate::date
  end

end
