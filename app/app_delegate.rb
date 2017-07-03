class AppDelegate

  include CDQ

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
    cdq.setup

    @last_answer = ''

    NSUserDefaults.standardUserDefaults.registerDefaults PREFS_DEFAULTS

    @snap_path = File.join(NSBundle.mainBundle.resourcePath, 'imagesnap')
    application_support = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).first

    @snippet_path = File.join(application_support, 'wassup', 'snippets')
    Motion::FileUtils.mkdir_p(@snippet_path) unless File.exist?(@snippet_path)

    setDateFormats
    buildMenu

    ask_and_schedule
  end


  def applicationShouldOpenUntitledFile sender
    return false;
  end

  def openPreferences(sender)
    @prefs_controller = PrefsWindowController.alloc.init
    @prefs_controller.showWindow(self)
    @prefs_controller.window.orderFrontRegardless
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

  FMT = NSDateFormatter.new
  FMT.setDateFormat "ddMMYYYY-HHmmss"

  def ask
    suffix = FMT.stringFromDate Time.now

    if NSUserDefaults.standardUserDefaults.objectForKey('TakePictures') == NSOnState
      image = File.join(@snippet_path, "snippet-#{suffix}.png")
      system("#{@snap_path.inspect} -w 0.5 #{image.inspect}")
    end

    picked = PROMPTS[rand*PROMPTS.length]

    answer = input(picked, @last_answer)
    if answer
      @last_answer = answer
      log(@last_answer)
    end
  end

  def setDateFormats
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"
    @dayFormat = NSDateFormatter.new
    @dayFormat.setDateFormat "EEEE"
    @timeFormat = NSDateFormatter.new
    @timeFormat.setDateFormat " HH:mm"
  end

  def log(msg)
    Entry.create(title: msg)
    cdq.save
  end

  def coredata(msg)
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

    input_field.stringValue if button == 1
  end

  def export_csv_log
    rows = []
    Entry.all.sort_by('created_at').each do |entry|
      rows << [entry.created_at, entry.title]
    end

    panel = NSSavePanel.savePanel

    panel.setNameFieldStringValue "time-entries.csv"

    panel.beginWithCompletionHandler(
      lambda do | result |
        if result == NSFileHandlingPanelOKButton
          rows.to_csv.writeToFile(panel.URL, atomically:true, encoding:NSUTF8StringEncoding, error:nil)
        end
      end
    )
  end

  def reset_log
    p 'reset log'
    Entry.all.each do |entry|
      entry.destroy
    end
    cdq.save
  end

  def create_markdown_file(file = File.join(@snippet_path, 'snippets.md'))

    Motion::FileUtils.rm(file) if File.exist?(file)

    snippets_md ||= open(file, 'ab')
    snippets_md << "# Time report\n"
    snippets_md << "\n"
    snippets_md << "| date       | day       | time     | activity                                 |\n"
    snippets_md << "|------------|-----------|----------|------------------------------------------|\n"

    Entry.all.sort_by('created_at').each do |entry|

      date = @dateFormat.stringFromDate entry.created_at
      day = @dayFormat.stringFromDate entry.created_at
      time = @timeFormat.stringFromDate entry.created_at

      snippets_md << "| #{date} | #{day} | #{time} | #{entry.title}                                  |\n"
    end

    snippets_md.flush

  end


  def show_log

    temp_file = File.join(@snippet_path, 'snippets_temp.md')
    create_markdown_file( temp_file )

    content = NSString.stringWithContentsOfFile(temp_file, encoding:NSUTF8StringEncoding, error:nil)

    parser = MarkdownIt::Parser.new({ html: true, linkify: true, typographer: true })
    html = parser.render(content)

    css='https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css'
    header = '<html><head><link rel="stylesheet" href="'+css+'"></head><body class="markdown-body">'
    footer = '</body></html>'
    @logweb_controller = LogwebWindowController.alloc.init
    @logweb_controller.update_webview(header+html+footer)
    @logweb_controller.showWindow(self)
    @logweb_controller.window.orderFrontRegardless
  end

end
