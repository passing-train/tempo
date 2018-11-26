class AppDelegate
  def buildMenu
    @mainMenu = NSMenu.new

    appName = NSBundle.mainBundle.infoDictionary['CFBundleName']
    addMenu(appName) do
      addItemWithTitle("About #{appName}", action: 'orderFrontStandardAboutPanel:', keyEquivalent: '')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Preferences', action: 'openPreferences:', keyEquivalent: ',')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle("Hide #{appName}", action: 'hide:', keyEquivalent: 'h')
      item = addItemWithTitle('Hide Others', action: 'hideOtherApplications:', keyEquivalent: 'H')
      item.keyEquivalentModifierMask = NSCommandKeyMask|NSAlternateKeyMask
      addItemWithTitle('Show All', action: 'unhideAllApplications:', keyEquivalent: '')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle("Quit #{appName}", action: 'terminate:', keyEquivalent: 'q')
    end

    addMenu('File') do
      addItemWithTitle('Ask', action: 'ask_early', keyEquivalent: '!')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Export Day Totals to CSV for Exact Online', action: 'export_exact_day_totals', keyEquivalent: 't')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Clear database', action: 'reset_log', keyEquivalent: '')
      addItemWithTitle('Close', action: 'performClose:', keyEquivalent: 'w')
    end

    addMenu('Edit') do
      addItemWithTitle('Undo', action: 'undo:', keyEquivalent: 'z')
      addItemWithTitle('Redo', action: 'redo:', keyEquivalent: 'Z')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Time entries', action: 'open_list_entries_window', keyEquivalent: 'e')
      addItemWithTitle('Customers', action: 'open_manage_customers_window', keyEquivalent: 'k')
      addItemWithTitle('Projects', action: 'open_manage_projects_window', keyEquivalent: 'd')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Cut', action: 'cut:', keyEquivalent: 'x')
      addItemWithTitle('Copy', action: 'copy:', keyEquivalent: 'c')
      addItemWithTitle('Paste', action: 'paste:', keyEquivalent: 'v')
      addItemWithTitle('Delete', action: 'delete:', keyEquivalent: '')
      addItemWithTitle('Select All', action: 'selectAll:', keyEquivalent: 'a')
    end

    addMenu('Log') do
      addItemWithTitle('Show Day Totals Log', action: 'show_day_totals_log', keyEquivalent: '')
    end
    addMenu('Developer') do
      addItemWithTitle('Export Log to CSV', action: 'export_csv_log', keyEquivalent: '')
      addItemWithTitle('Show Flat Time Log', action: 'show_flat_log', keyEquivalent: '')
      addItemWithTitle('Show Cumulated Time Log', action: 'show_cum_log', keyEquivalent: '')
    end

    NSApp.helpMenu = addMenu('Help') do
      addItemWithTitle("#{appName} Help", action: 'showHelp:', keyEquivalent: '?')
    end.menu

    NSApp.mainMenu = @mainMenu
  end

  private

  def addMenu(title, &b)
    item = createMenu(title, &b)
    @mainMenu.addItem item
    item
  end

  def createMenu(title, &b)
    menu = NSMenu.alloc.initWithTitle(title)
    menu.instance_eval(&b) if b
    item = NSMenuItem.alloc.initWithTitle(title, action: nil, keyEquivalent: '')
    item.submenu = menu
    item
  end
end
