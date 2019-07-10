class ManageWindowControllerPrototype < NSWindowController

  include CDQ

  def reload_window
    populate
    @table_view.reloadData
  end

  def call_reload_all_windows
    NSApp.delegate.reload_all_windows
  end

  def alert_confirm title, text
    alert = NSAlert.new
    alert.messageText = title
    alert.informativeText = text
    alert.alertStyle = NSWarningAlertStyle
    alert.addButtonWithTitle("Yes")
    alert.addButtonWithTitle("Cancel")
    response = alert.runModal
    if response == 1000
      return true
    else
      return false
    end
  end



end
