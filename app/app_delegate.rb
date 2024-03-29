class AppDelegate

  attr_reader :export
  attr_reader :ask
  attr_reader :status_item

  include CDQ

  PREFS_DEFAULTS = {
    'AskInterval' => 20,
    'VaryInterval' => false
  }

  def applicationDidFinishLaunching(notification)

    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)

    @hotKeyManager = SPHotKeyManager::instance
    hk = SPHotKey.alloc.initWithTarget(self, action:'ask_early', object:nil, keyCode:0x12, modifierFlags:(NSCommandKeyMask+NSShiftKeyMask))
    @hotKeyManager.registerHotKey(hk)

    cdq.setup
    NSUserDefaults.standardUserDefaults.registerDefaults PREFS_DEFAULTS
    buildMenu
    setup_menu_bar
    init_all_windows
    reload_all_windows

    @export = Export.alloc.init
    @ask = Ask.alloc.init
    @ask.ask_and_schedule
    self.showNotification
  end

  def init_all_windows
    @list_entries_window_controller ||= ListEntriesWindowController.alloc.init
    @list_flat_entries_window_controller ||= ListFlatEntriesWindowController.alloc.init
    @list_manage_customers_constroller ||= ManageCustomersWindowController.alloc.init
    @list_manage_projects_constroller ||= ManageProjectsWindowController.alloc.init
  end

  def reload_all_windows
    p 'reload all windows'
    @list_entries_window_controller.reload_window
    @list_flat_entries_window_controller.reload_window
    @list_manage_customers_constroller.reload_window
    @list_manage_projects_constroller.reload_window
  end

  def setLastApp
    p 'record lastapp'
    @last_app = NSWorkspace.sharedWorkspace.frontmostApplication
  end

  def returnToLastApp
    p 'return to lastapp'
    @last_app.activateWithOptions(NSApplicationActivateIgnoringOtherApps)
  end


  def showNotification
    notification = NSUserNotification.alloc.init
    notification.title = "What's happening"
    notification.informativeText = "Please tell me where you're working on."
#    notification.soundName = NSUserNotificationDefaultSoundName
    NSUserNotificationCenter.defaultUserNotificationCenter.deliverNotification(notification)
  end

  def userNotificationCenter(center, didActivateNotification: notification)
    @status_item.popUpStatusItemMenu(@status_menu)
    center.removeDeliveredNotification(notification)
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
    @status_item.setImage(NSImage.imageNamed("menubar_Tempo"))
  end

  def set_menu_bar_normal
    @status_item.setImage(NSImage.imageNamed("menubar_normal"))
  end

  def applicationShouldOpenUntitledFile sender
    return false;
  end

  def ask_early
    @ask.ask_early
  end

  def open_list_entries_window
    @list_entries_window_controller.showWindow(self)
    @list_entries_window_controller.window.orderFrontRegardless
  end

  def open_list_flat_entries_window
    @list_flat_entries_window_controller.showWindow(self)
    @list_flat_entries_window_controller.window.orderFrontRegardless
  end

  def open_manage_customers_window
    @list_manage_customers_constroller.showWindow(self)
    @list_manage_customers_constroller.window.orderFrontRegardless
    #@list_manage_customers_constroller.tableUpdate
  end

  def open_manage_projects_window
    @list_manage_projects_constroller.showWindow(self)
    @list_manage_projects_constroller.window.orderFrontRegardless
    #@list_manage_projects_constroller.tableUpdate
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

  def export_exact_day_totals
    @export.export_exact_day_totals
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

  def delete_all_entries
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle  "OK"
    alert.addButtonWithTitle "Cancel"
    alert.setMessageText "Delete all activity entries?"
    alert.setInformativeText "Deleted entries cannot be restored."
    alert.setAlertStyle NSWarningAlertStyle

    if alert.runModal == NSAlertFirstButtonReturn
      Entry.where(:sticky).eq(0).each do |entry|
        entry.destroy
      end

      cdq.save
      @ask.reset_last
      reload_all_windows
    end
  end

  def flush_sticky_entries
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle  "OK"
    alert.addButtonWithTitle "Cancel"
    alert.setMessageText "Flush time in all sticky entries?"
    alert.setInformativeText "Time calculations cannot be restored."
    alert.setAlertStyle NSWarningAlertStyle

    if alert.runModal == NSAlertFirstButtonReturn
      Entry.where(:sticky).eq(1).each do |entry|
        entry.time_delta = 0
        entry.extra_time = 0
      end

      cdq.save
    end
  end

end
