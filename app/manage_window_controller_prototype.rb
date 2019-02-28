class ManageWindowControllerPrototype < NSWindowController

  include CDQ

  def reload_window
    populate
    @table_view.reloadData
  end

  def call_reload_all_windows
    NSApp.delegate.reload_all_windows
  end
end
