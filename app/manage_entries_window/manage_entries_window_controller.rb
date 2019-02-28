class ListEntriesWindowController < ManageWindowControllerPrototype

  def layout
    @layout ||= ListEntriesWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window
      setDateFormats

      @title = 'NSTableView'
      @layout = layout

      @search_field = @layout.get(:search_field)
      @search_field.delegate = self

      @fltr_customer_field = @layout.get(:fltr_customer_field)
      @fltr_customer_field.delegate = self

      @sorting_column = :title
      @sorting_ascending = true
      populate

      init_controls
      init_sort_descriptors

      @last_selected_row = nil
      disable_edit
    end
  end

  def init_controls

    @button_update = @layout.get(:button_update)
    @button_update.target = self
    @button_update.action = 'update:'

    @button_delete = @layout.get(:button_delete)
    @button_delete.target = self
    @button_delete.action = 'delete:'

    @button_cancel = @layout.get(:button_cancel)
    @button_cancel.target = self
    @button_cancel.action = 'cancel:'
    @button_cancel.setEnabled false

    @table_view = @layout.get(:table_view)
    @table_view.delegate = self
    @table_view.dataSource = self

    @entry_field = @layout.get(:entry_field)

    @customer_field = @layout.get(:customer_field)
    @customer_field.tableViewDelegate = self

    @project_field = @layout.get(:project_field)
    @project_field.tableViewDelegate = self

    @project_description = @layout.get(:project_description)

    @check_no_export = @layout.get(:check_no_export)
    @check_sticky = @layout.get(:check_sticky)

    @addextratime_field = @layout.get(:addextratime_field)

    @button_lastdayextra = @layout.get(:button_lastdayextra)
    @button_lastdayextra.target = self
    @button_lastdayextra.action = 'add_extra_time_last_day:'
  end

  def init_sort_descriptors

      #@table_view.tableColumns.each do |col|
      #  p col
      #  p col.identifier
      #  sortDescriptor = NSSortDescriptor.sortDescriptorWithKey(col.identifier, ascending:true, selector:'compare:')
      #  col.setSortDescriptorPrototype sortDescriptor
      #end

      descriptorEntry = NSSortDescriptor.sortDescriptorWithKey('entry' , ascending:true, selector:'compare:')
      @table_view.tableColumns[0].sortDescriptorPrototype = descriptorEntry

      descriptorCustomer = NSSortDescriptor.sortDescriptorWithKey('customer' , ascending:true, selector:'compare:')
      @table_view.tableColumns[1].sortDescriptorPrototype = descriptorCustomer

      descriptorProject = NSSortDescriptor.sortDescriptorWithKey('project' , ascending:true, selector:'compare:')
      @table_view.tableColumns[2].sortDescriptorPrototype = descriptorProject

#      descriptorTimeToday = NSSortDescriptor.sortDescriptorWithKey('time_today' , ascending:true, selector:'compare:')
#      @table_view.tableColumns[4].sortDescriptorPrototype = descriptorTimeToday
#
#      descriptorTotalTime = NSSortDescriptor.sortDescriptorWithKey('total_time' , ascending:true, selector:'compare:')
#      @table_view.tableColumns[3].sortDescriptorPrototype = descriptorTotalTime
  end

  def controlTextDidChange sender
    #NSTextField *textField = [notification object];
    #NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    p "text control did change"

    call_reload_all_windows
  end

  def cancel sender
    disable_edit
    @table_view.deselectAll sender
    self.window.makeFirstResponder @table_view
  end

  def delete sender

    @last_selected_row = @table_view.selectedRow
    Entry.where(:title).eq(@entries[@last_selected_row].title).each do |e|
      e.destroy
    end

    cdq.save
    call_reload_all_windows
    disable_edit

    self.window.makeFirstResponder @table_view
  end

  def keyUp(event)
    case event.keyCode
    when 36, 48, 51, 49 # return, tab, space
      @customer_field.autoCompletePopover.close()
      @project_field.autoCompletePopover.close()
    else
    end
  end

  def customer_by_name name
    customers = Customer.where(:name).eq(name)
    if customers.count == 1
      customers.first
    else
      nil
    end
  end

  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)

    if textField.wu_identifier == 'customer'
      matches = Customer.where(:name).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:name).uniq
      @project_field.autoCompletePopover.close()

    elsif textField.wu_identifier == 'project'
      @customer_field.autoCompletePopover.close()

      customer = customer_by_name @customer_field.stringValue.to_s
      if customer
        matches = Project.where(:project_id).contains(textField.stringValue,NSCaseInsensitivePredicateOption)
          .or(:project_description).contains(textField.stringValue,NSCaseInsensitivePredicateOption)
          .and(cdq(:customer_id).eq(customer.customer_id.to_i).or.lt(1))
          .map(&:project_id).uniq
      else
        matches = Project.where(:project_id).contains(textField.stringValue,NSCaseInsensitivePredicateOption)
          .or(:project_description).contains(textField.stringValue,NSCaseInsensitivePredicateOption)
          .map(&:project_id).uniq
      end
    end

    matches
  end

  def setDateFormats
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"
    @dayFormat = NSDateFormatter.new
    @dayFormat.setDateFormat "EEEE"
    @timeFormat = NSDateFormatter.new
    @timeFormat.setDateFormat " HH:mm"
  end

  def populate sortBy=:title, ascending=true

    if @sorting_ascending
      order = :ascending
    else
      order = :descending
    end

    customer = customer_by_name @fltr_customer_field.stringValue unless @fltr_customer_field.stringValue == ''
    freesearchfield = @search_field.stringValue unless @search_field.stringValue == ''

    if customer.nil? and @fltr_customer_field.stringValue != ''
      entries = []

    elsif freesearchfield and customer
      entries = Entry.where("title LIKE[c] %@", "*#{freesearchfield}*").where(:customer_id).eq(customer.customer_id).sort_by(@sorting_column, order: order).map(&:title).uniq

    elsif freesearchfield and customer.nil?
      entries = Entry.where("title LIKE[c] %@", "*#{freesearchfield}*").sort_by(@sorting_column, order: order).map(&:title).uniq

    elsif freesearchfield.nil? and customer
      entries = Entry.where(:customer_id).eq(customer.customer_id.to_i).sort_by(@sorting_column, order: order).map(&:title).uniq

    else
      entries = Entry.sort_by(@sorting_column, order: order).map(&:title).uniq
    end

    @entries = []

    entries.each do |e|
      @entries << Entry.where(:title).eq(e).first
    end
  end

  def update sender
    @last_selected_row = @table_view.selectedRow

    Entry.where(:title).eq(@entries[@last_selected_row].title).each do |e|

      e.title = @entry_field.stringValue.to_s

      project = Project.where(:project_id).eq(@project_field.stringValue.to_s).first
      p project

      if project.nil? and @project_field.stringValue != ''
        project = Project.create(project_id: @project_field.stringValue.to_s)
      end
      e.project_id = @project_field.stringValue.to_s

      if @check_sticky.state == NSOnState
        e.sticky = 1
      else
        e.sticky = 0
      end

      if @check_no_export.state == NSOnState
        e.not_in_export = 1
      else
        e.not_in_export = 0
      end

      customer = customer_by_name @customer_field.stringValue.to_s
      if customer
        e.customer_id = customer.customer_id.to_i
      end
    end

    cdq.save
    call_reload_all_windows
    disable_edit

    indexSet = NSIndexSet.indexSetWithIndex @last_selected_row
    @table_view.selectRowIndexes(indexSet, byExtendingSelection:false)
    self.window.makeFirstResponder @table_view
  end

  def add_extra_time_last_day sender
    if @addextratime_field.stringValue != @addextratime_field.stringValue.to_s.to_i.to_s and
        @addextratime_field.stringValue != @addextratime_field.stringValue.to_s.to_f.to_s

      alert = NSAlert.alloc.init
      alert.setMessageText  "Can't add time"
      alert.setInformativeText "Please enter a float value. 1 and a half hour is 1.5."
      alert.addButtonWithTitle "Ok"
      alert.runModal
    else
      @last_selected_row = @table_view.selectedRow

      last_day_entry = Entry.where(:title).eq(@entries[@last_selected_row].title).sort_by('created_at').last
      last_day_entry.extra_time = last_day_entry.extra_time + TimeUtility::format_time_from_metric_hours_to_seconds(@addextratime_field.stringValue.to_f)

      cdq.save
      @table_view.reloadData

      disable_edit
      indexSet = NSIndexSet.indexSetWithIndex @last_selected_row
      @table_view.selectRowIndexes(indexSet, byExtendingSelection:false)
      self.window.makeFirstResponder @table_view

    end
    @addextratime_field.setStringValue ''
  end

  def disable_edit
      @entry_field.setStringValue ''
      @project_field.setStringValue ''
      @project_description.setStringValue ''
      @customer_field.setStringValue ''

      @entry_field.setEditable false
      @project_field.setEditable false
      @customer_field.setEditable false

      @button_update.setEnabled false
      @button_delete.setEnabled false
      @button_cancel.setEnabled false

      @check_no_export.setEnabled false

      @addextratime_field.setStringValue ''
      @addextratime_field.setEditable false
      @button_lastdayextra.setEnabled false
  end

  def enable_edit
      @entry_field.setEditable true
      @project_field.setEditable true
      @customer_field.setEditable true
      @button_update.setEnabled true
      @button_delete.setEnabled true
      @button_cancel.setEnabled true

      @check_no_export.setEnabled true

      @addextratime_field.setEditable true
      @button_lastdayextra.setEnabled true
  end

  def tableViewSelectionDidChange sender
    idx = @table_view.selectedRow
    if idx == -1
      disable_edit
    else
      enable_edit
      @entry_field.setStringValue @entries[idx].title
      @project_field.setStringValue @entries[idx].project_id.to_s
      @project_description.setStringValue @entries[idx].project_description.to_s
      @customer_field.setStringValue @entries[idx].customer_name

      if @entries[idx].not_in_export == 1
        @check_no_export.setState NSOnState
      else
        @check_no_export.setState NSOffState
      end

      if @entries[idx].sticky == 1
        @check_sticky.setState NSOnState
      else
        @check_sticky.setState NSOffState
      end


      #customer = Customer.where(:customer_id).eq(@entries[idx].customer_id).first
      #if customer
        #@customer_field.setStringValue customer.name.to_s
      #else
        #@customer_field.setStringValue ''
      #end

    end
  end

  def numberOfRowsInTableView(table_view)
    @entries.length
  end

  def tableView(table_view, viewForTableColumn: column, row: rowidx)
    text_field = table_view.makeViewWithIdentifier(column.identifier, owner: self)

    unless text_field
      text_field = NSTextField.alloc.initWithFrame([[0, 0], [column.width, 0]])
      text_field.identifier = column.identifier
      text_field.editable = false
      text_field.drawsBackground = false
      text_field.bezeled = false
    end

    record = @entries[rowidx]

    case column.identifier
    when 'entry'
      text_field.stringValue = record.title
    when 'customer'
      text_field.stringValue = record.customer_name
      #customer = Customer.where(:customer_id).eq(record.customer_id).first
      #if customer
        #text_field.stringValue = customer.name.to_s
      #end
    when 'project'
      text_field.stringValue = record.project_id.to_s
    when 'total_day_time'
      text_field.stringValue = record.time_today
    when 'total_time'
      text_field.stringValue = record.total_time
    end

    return text_field
  end

  def tableView(aTableView, sortDescriptorsDidChange:oldDescriptors)

    case aTableView.sortDescriptors[0].key
    when 'entry'
      @sorting_column = :title
#      populate :title, aTableView.sortDescriptors[0].ascending
    when 'customer'
      @sorting_column = :customer_id
#      populate :customer_id, aTableView.sortDescriptors[0].ascending
    when 'project'
      @sorting_column = :customer_id
      #populate :project_id, aTableView.sortDescriptors[0].ascending
#    when 'total_day_time'
#      populate :time_today, aTableView.sortDescriptors[0].ascending
#    when 'total_time'
#      populate :total_time, aTableView.sortDescriptors[0].ascending
    end

    @sorting_ascending = aTableView.sortDescriptors[0].ascending
    populate
    @table_view.reloadData
  end

end
