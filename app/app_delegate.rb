class AppDelegate

  attr_reader :export
  attr_reader :ask

  include CDQ

  PREFS_DEFAULTS = {
    'AskInterval' => 20
  }

  def applicationDidFinishLaunching(notification)

    cdq.setup
    NSUserDefaults.standardUserDefaults.registerDefaults PREFS_DEFAULTS
    buildMenu

    @export = Export.alloc.init
    @ask = Ask.alloc.init
    @ask.ask_and_schedule
  end

  def applicationShouldOpenUntitledFile sender
    return false;
  end

  def openPreferences(sender)
    @prefs_controller ||= PrefsWindowController.alloc.init
    @prefs_controller.showWindow(self)
    @prefs_controller.window.orderFrontRegardless
  end

  def export_csv_log
    @export.export_csv_log
  end

  def show_log
    @logweb_controller ||= LogwebWindowController.alloc.init
    @logweb_controller.update_webview()
    @logweb_controller.showWindow(self)
    @logweb_controller.window.orderFrontRegardless
  end

  def reset_log
    Entry.all.each do |entry|
      entry.destroy
    end
    cdq.save
  end

end
