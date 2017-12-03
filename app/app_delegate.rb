class AppDelegate

  attr_reader :export
  attr_reader :ask
  attr_reader :status_item

  include CDQ

  PREFS_DEFAULTS = {
    'AskInterval' => 20
  }

  def applicationDidFinishLaunching(notification)

    @hotKeyManager = SPHotKeyManager::instance
    hk = SPHotKey.alloc.initWithTarget(self, action:'ask_early', object:nil, keyCode:0x12, modifierFlags:(NSCommandKeyMask+NSShiftKeyMask))
    @hotKeyManager.registerHotKey(hk)

    cdq.setup
    NSUserDefaults.standardUserDefaults.registerDefaults PREFS_DEFAULTS
    buildMenu
    setup_menu_bar

    @export = Export.alloc.init
    @ask = Ask.alloc.init
    @ask.ask_and_schedule
  end

  def clicked_menu_bar sender
    ask_early
    NSRunningApplication.currentApplication.activateWithOptions(NSApplicationActivateIgnoringOtherApps)
  end

  def setup_menu_bar
    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(24.0)
    @status_item.setHighlightMode(false)
    @status_item.setImage(NSImage.imageNamed("menubar_normal"))
    @status_item.setTarget(self)
    @status_item.setAction('clicked_menu_bar:')
  end

  def set_menu_bar_active
    @status_item.setImage(NSImage.imageNamed("menubar_wassup"))
  end

  def set_menu_bar_normal
    @status_item.setImage(NSImage.imageNamed("menubar_normal"))
  end

  def applicationShouldOpenUntitledFile sender
    return false;
  end

  def open_ask_window
    @ask_window_controller ||= AskWindowController.alloc.init
    @ask_window_controller.showWindow(self)
    @ask_window_controller.window.orderFrontRegardless
  end

  def openPreferences(sender)
    @prefs_controller ||= PrefsWindowController.alloc.init
    @prefs_controller.showWindow(self)
    @prefs_controller.window.orderFrontRegardless
  end

  def export_csv_log
    @export.export_csv_log
  end
  def export_excel_daytotals
    @export.export_excel_daytotals
  end

  def ask_early
    @ask.ask_early
  end

  def logweb_controller_action action
    @logweb_controller ||= LogwebWindowController.alloc.init
    @logweb_controller.send(action)
    @logweb_controller.showWindow(self)
    @logweb_controller.window.orderFrontRegardless
  end

  def show_flat_log
    logweb_controller_action 'update_webview_with_flat_log'
  end

  def show_cum_log
    logweb_controller_action 'update_webview_with_cum_log'
  end

  def show_day_totals_log
    logweb_controller_action 'update_webview_with_day_totals'
  end

  def reset_log
    Entry.all.each do |entry|
      entry.destroy
    end
    cdq.save
    @ask.reset_last
  end

end
