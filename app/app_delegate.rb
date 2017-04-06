class AppDelegate
  PREFS_DEFAULTS = {
    'AskInterval' => 20,
    'TakePictures' => NSOnState
  }

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

  def applicationDidFinishLaunching(notification)

    @last_answer = ''

    NSUserDefaults.standardUserDefaults.registerDefaults PREFS_DEFAULTS

    @snap_path = File.join(NSBundle.mainBundle.resourcePath, 'imagesnap')
    application_support = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).first

    @snippet_path = File.join(application_support, 'wassup', 'snippets')
    Motion::FileUtils.mkdir_p(@snippet_path) unless File.exist?(@snippet_path)

    setDateFormats
    prep_log
    prep_log_md
    log('[Starting up (rubymotion)]')
    buildMenu
    ask_and_schedule
  end

  def openPreferences(sender)
    @prefs_controller = PrefsWindowController.alloc.init
    @prefs_controller.showWindow(self)
    @prefs_controller.window.orderFrontRegardless
  end


  def ask_early
    if @timer
      @timer.fire
    else
      alert = NSAlert.alertWithMessageText('The prompt is already being displayed',
                      defaultButton: "OK", alternateButton: nil,
                      otherButton: nil, informativeTextWithFormat: "")
      alert.runModal
    end
  end

  def ask_and_schedule
    old_app = NSWorkspace.sharedWorkspace.frontmostApplication
    @timer = nil
    begin
      ask
    rescue => e
      alert = NSAlert.alertWithMessageText('Problem asking for input: ' + e.message,
                      defaultButton: "OK", alternateButton: nil,
                      otherButton: nil, informativeTextWithFormat: "")
      alert.runModal
    end
    # -5..5 + 20 yields a range of 15-25 minutes.

    interval = NSUserDefaults.standardUserDefaults.integerForKey('AskInterval')
    p interval

    wait_time = (((rand*10).to_i-5)+interval)*60
    @timer = NSTimer.scheduledTimerWithTimeInterval(wait_time, target: self, selector: 'ask_and_schedule', userInfo: nil, repeats: false)
    old_app.activateWithOptions(NSApplicationActivateIgnoringOtherApps)
  end

  FMT = NSDateFormatter.new
  FMT.setDateFormat "ddMMYYYY-HHmmss"

  def ask
    suffix = FMT.stringFromDate Time.now

    if NSUserDefaults.standardUserDefaults.objectForKey('TakePictures') == NSOnState
      image = File.join(@snippet_path, "snippet-#{suffix}.png")
      system("#{@snap_path.inspect} -w 0.5 #{image.inspect}")
    end

    picked = PROMPTS[rand*PROMPTS.length]

    @last_answer = input(picked, @last_answer)
#    @last_answer = answer
    log(@last_answer)
  end

  def prep_log_md(file = File.join(@snippet_path, 'snippets.md'))

    @logfile_md = file

    if File.exist?(file)
      @snippets_md ||= open(file, 'ab')
    else
      p 'no'
      init_log_md file
    end
  end

  def init_log_md file
    @snippets_md ||= open(file, 'ab')
    @snippets_md << "# Time report\n"
    @snippets_md << "\n"
    @snippets_md << "| date       | day       | time     | activity                                 |\n"
    @snippets_md << "|------------|-----------|----------|------------------------------------------|\n"

    @snippets_md.flush
  end

  def setDateFormats
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"
    @dayFormat = NSDateFormatter.new
    @dayFormat.setDateFormat "EEEE"
    @timeFormat = NSDateFormatter.new
    @timeFormat.setDateFormat " HH:mm"
  end

  def log_md(msg)

    date = @dateFormat.stringFromDate Time.now
    day = @dayFormat.stringFromDate Time.now
    time = @timeFormat.stringFromDate Time.now

    @snippets_md << "| #{date} | #{day} | #{time} | #{msg}                                  |\n"
    @snippets_md.flush
  end

  def prep_log(file = File.join(@snippet_path, 'snippets.txt'))
    @logfile = file
    @snippets ||= open(file, 'ab')
  end

  def log(msg)
    log_txt msg
    log_md msg
  end

  def log_txt(msg)
    @snippets << Time.now.to_s << ': ' << msg << "\n"
    @snippets.flush
  end

  def input(prompt, default_value="")
    alert = NSAlert.alertWithMessageText(prompt, defaultButton: "OK", alternateButton: "Cancel", otherButton: nil, informativeTextWithFormat: "")
    input_field = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
    input_field.stringValue = default_value
    alert.accessoryView = input_field
    alert.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
    alert.window.level = NSFloatingWindowLevel
    alert.window.setInitialFirstResponder(input_field)
    alert.window.makeFirstResponder(input_field)
    button = alert.runModal

    answer = input_field.stringValue if button == 1
    (answer.nil? || answer.empty?) ? '...' : answer
  end

  def finderView
    files = [NSURL.fileURLWithPath(@logfile_md)]
    NSWorkspace.sharedWorkspace.activateFileViewerSelectingURLs(files)
  end
end
