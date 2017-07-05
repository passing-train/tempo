#module AutoCompleteTableViewDelegate
#
#  def textField(somevar, completions, forPartialWordRange, indexOfSelectedItem)
#    ''
#  end
#end
#

#@objc protocol AutoCompleteTableViewDelegate:NSObjectProtocol{
#    func textField(_ textField:NSTextField,completions words:[String],forPartialWordRange charRange:NSRange,indexOfSelectedItem index:Int) ->[String]
#    @objc optional func didSelectItem(_ selectedItem: String)
#}




class Ask

#  include AutoCompleteTableViewDelegate
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

    old_app = NSWorkspace.sharedWorkspace.frontmostApplication
    @timer = nil
    begin
      ask
    rescue => e
      NSLog("Error %@", e)
      alert = NSAlert.alertWithMessageText('Problem asking for input: ' + e.message,
                                           defaultButton: "OK", alternateButton: nil,
                                           otherButton: nil, informativeTextWithFormat: "")
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

    answer = input(picked, @last_answer)

    p answer
    if answer
      @last_answer = answer
      log(@last_answer)
    end
  end

  def input(prompt, default_value="")
    alert = NSAlert.alertWithMessageText(prompt, defaultButton: "OK", alternateButton: "Cancel", otherButton: nil, informativeTextWithFormat: "")

    #@AutoCompleteTableViewDelegate

#    input_field = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
    input_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
    #input_field = AutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
    input_field.awakeFromNib
    input_field.stringValue = default_value

    input_field.tableViewDelegate = self
    input_field.delegate = self

    alert.accessoryView = input_field
    alert.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
    alert.window.level = NSFloatingWindowLevel
    alert.window.setInitialFirstResponder(input_field)
    alert.window.makeFirstResponder(input_field)
    button = alert.runModal

    input_field.stringValue if button == 1
  end

  def didSelectItem(somevar, selectedItem: aSelectedItem)
    if aSelectedItem
      input_field.stringValue = aSelectedItem
    end
    NSLog("%@", aSelectedItem)
  end

  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)

    NSLog('text:%@',textField.stringValue)
    matches = ['hallo' , 'dag']
    matches
  end

#  def textField(somevar, completions, forPartialWordRange, indexOfSelectedItem)
#    NSLog('hallo')
#    matches = ['hallo' , 'dag']
#    matches
#  end
=begin
      func textField(_ textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        var matches = [String]()
        //先按简拼  再按全拼  并保留上一次的match
        for station in stationData.allStation
        {
            if let _ = station.FirstLetter.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
            {
                matches.append(station.Name)
            }
        }
        if(matches.count == 0)
        {
            for station in stationData.allStation
            {
                if let _ = station.Spell.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
                {
                    matches.append(station.Name)
                }
            }
        }
        //再按汉字
        if(matches.count == 0)
        {
            for station in stationData.allStation
            {
                if let _ = station.Name.range(of: textField.stringValue, options: NSString.CompareOptions.anchored)
                {
                    matches.append(station.Name)
                }
            }
        }

        return matches
    }

=end

  def log(msg)

    if @last_time

      last_entry =  Entry.last
      now = NSDate::date

      distanceBetweenDates = now.timeIntervalSinceDate(last_entry.created_at)
      p distanceBetweenDates.to_i

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
