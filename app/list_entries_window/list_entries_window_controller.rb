class ListEntriesWindowController < NSWindowController

  include CDQ

  def layout
    @layout ||= ListEntriesWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      setDateFormats

      @title = 'NSTableView'
      @layout = layout

      populateEntries

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

      #@table_view.tableColumns.each do |col|
        #sortDescriptor = NSSortDescriptor.sortDescriptorWithKey(col.identifier, ascending:true, selector:'compare:')
        #col.setSortDescriptorPrototype sortDescriptor
      #end

      @customer_field = @layout.get(:customer_field)
      @customer_field.tableViewDelegate = self

      @project_field = @layout.get(:project_field)
      @project_field.tableViewDelegate = self

      @addextratime_field = @layout.get(:addextratime_field)

      @button_lastdayextra = @layout.get(:button_lastdayextra)
      @button_lastdayextra.target = self
      @button_lastdayextra.action = 'add_extra_time_last_day:'

      @last_selected_row = nil
      disable_edit
    end

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
    populateEntries
    @table_view.reloadData
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

  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)

    if textField.wu_identifier == 'customer'
      matches = Customer.where(:name).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:name).uniq
    else
      matches = Project.where(:project_id).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:project_id).uniq
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


  def populateEntries sortBy=:title

    entries = Entry.sort_by(sortBy).map(&:title).uniq

    @entries = []

    entries.each do |e|
      @entries << Entry.where(:title).eq(e).first
    end
  end

  def tableUpdate
    populateEntries
    @table_view.reloadData
  end

  def update sender
    @last_selected_row = @table_view.selectedRow

    Entry.where(:title).eq(@entries[@last_selected_row].title).each do |e|

      e.title = @entry_field.stringValue.to_s
      e.project_id = @project_field.stringValue.to_s

      customer = Customer.where(:name).eq(@customer_field.stringValue.to_s).first
      if customer
        e.customer_id = customer.customer_id.to_i
      end
    end

    cdq.save
    populateEntries
    @table_view.reloadData
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
      @customer_field.setStringValue ''

      @entry_field.setEditable false
      @project_field.setEditable false
      @customer_field.setEditable false

      @button_update.setEnabled false
      @button_delete.setEnabled false
      @button_cancel.setEnabled false


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
      @customer_field.setStringValue @entries[idx].customer_name

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
    p oldDescriptors
    p 'sorting'
    p aTableView.sortDescriptors
    p aTableView.sortDescriptors[0].key

    #case aTableView.sortDescriptors[0].key
    #when 'entry'
      #populateEntries :title
    #when 'customer'
      #populateEntries :customer_id
    #when 'project'
      #populateEntries :project_id
    #when 'total_day_time'
    #when 'total_time'
    #end

    p @entries

    @entries = @entries.sortedArrayUsingDescriptors aTableView.sortDescriptors
    p @entries
    @table_view.reloadData
    #[aTableView reloadData];
  end

end
