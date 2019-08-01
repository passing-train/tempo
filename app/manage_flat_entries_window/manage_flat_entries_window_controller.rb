class ListFlatEntriesWindowController < ManageWindowControllerPrototype

  def layout
    @layout ||= ListFlatEntriesWindowLayout.new
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

      @sorting_column = :created_at
      @sorting_ascending = true
      populate

      init_controls
      init_sort_descriptors

      @last_selected_row = nil
      disable_edit
      disable_multi_edit
    end
  end

  def init_controls

    @button_update = @layout.get(:button_update)
    @button_update.target = self
    @button_update.action = 'update:'

    @button_delete = @layout.get(:button_delete)
    @button_delete.target = self
    @button_delete.action = 'delete:'

    @button_multi_delete = @layout.get(:button_multi_delete)
    @button_multi_delete.target = self
    @button_multi_delete.action = 'multi_delete:'

    @button_cancel = @layout.get(:button_cancel)
    @button_cancel.target = self
    @button_cancel.action = 'cancel:'
    @button_cancel.setEnabled false

    @table_view = @layout.get(:table_view)
    @table_view.delegate = self
    @table_view.dataSource = self
    @table_view.allowsMultipleSelection = true

    @entry_field = @layout.get(:entry_field)

    @customer_field = @layout.get(:customer_field)
    @customer_field.tableViewDelegate = self

    @project_field = @layout.get(:project_field)
    @project_field.tableViewDelegate = self

    @project_description = @layout.get(:project_description)

    @addextratime_field = @layout.get(:addextratime_field)

    @button_lastdayextra = @layout.get(:button_lastdayextra)
    @button_lastdayextra.target = self
    @button_lastdayextra.action = 'add_extra_time_last_day:'
  end

  def init_sort_descriptors

      descriptorCreatedAt = NSSortDescriptor.sortDescriptorWithKey('created_at' , ascending:true, selector:'compare:')
      @table_view.tableColumns[0].sortDescriptorPrototype = descriptorCreatedAt

      descriptorEntry = NSSortDescriptor.sortDescriptorWithKey('entry' , ascending:true, selector:'compare:')
      @table_view.tableColumns[1].sortDescriptorPrototype = descriptorEntry

      descriptorCustomer = NSSortDescriptor.sortDescriptorWithKey('customer' , ascending:true, selector:'compare:')
      @table_view.tableColumns[2].sortDescriptorPrototype = descriptorCustomer

      descriptorProject = NSSortDescriptor.sortDescriptorWithKey('project' , ascending:true, selector:'compare:')
      @table_view.tableColumns[3].sortDescriptorPrototype = descriptorProject

  end

  def controlTextDidChange sender
    p "text control did change"

    call_reload_all_windows
  end

  def cancel sender
    disable_edit
    @table_view.deselectAll sender
    self.window.makeFirstResponder @table_view
  end

  def multi_delete sender

    text =  "Are you sure you want to delete these " + @table_view.selectedRowIndexes.count.to_s + " entries?"

    if alert_confirm("Delete entries",text)

      currentIndex = @table_view.selectedRowIndexes.firstIndex
      while currentIndex != NSNotFound

        Entry.where(:created_at).eq(@entries[currentIndex].created_at).first.destroy

        currentIndex = @table_view.selectedRowIndexes.indexGreaterThanIndex currentIndex
      end

      cdq.save
      call_reload_all_windows
      disable_multi_edit

      self.window.makeFirstResponder @table_view
    end

  end

  def delete sender

    @last_selected_row = @table_view.selectedRow
    Entry.where(:created_at).eq(@entries[@last_selected_row].created_at).first.destroy

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
      entries = Entry.where("title LIKE[c] %@", "*#{freesearchfield}*").where(:customer_id).eq(customer.customer_id).sort_by(@sorting_column, order: order)

    elsif freesearchfield and customer.nil?
      entries = Entry.where("title LIKE[c] %@", "*#{freesearchfield}*").sort_by(@sorting_column, order: order)

    elsif freesearchfield.nil? and customer
      entries = Entry.where(:customer_id).eq(customer.customer_id.to_i).sort_by(@sorting_column, order: order)

    else
      entries = Entry.sort_by(@sorting_column, order: order)
      entries = Entry.sort_by(@sorting_column, order: order)
    end

    #p entries

    @entries = []
    @entries = entries

    entries.each do |e|
      #p e.title
    end
  end

  def update sender
    @last_selected_row = @table_view.selectedRow

    e = Entry.where(:created_at).eq(@entries[@last_selected_row].created_at).first
    e.title = @entry_field.stringValue.to_s

    project = Project.where(:project_id).eq(@project_field.stringValue.to_s).first
    #p project

    if project.nil? and @project_field.stringValue != ''
      project = Project.create(project_id: @project_field.stringValue.to_s)
    end
    e.project_id = @project_field.stringValue.to_s

    customer = customer_by_name @customer_field.stringValue.to_s
    if customer
      e.customer_id = customer.customer_id.to_i
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
      alert.setInformativeText "Please enter the amount of minutes as a number. Add '-' to decrease time."
      alert.addButtonWithTitle "Ok"
      alert.runModal
    else

      @last_selected_row = @table_view.selectedRow
      last_day_entry = Entry.where(:created_at).eq(@entries[@last_selected_row].created_at).sort_by('created_at').first
      last_day_entry.extra_time = last_day_entry.extra_time + (@addextratime_field.stringValue.to_i * 60)

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

    if @table_view.selectedRowIndexes.count > 0

      disable_multi_edit
      idx = @table_view.selectedRow
      enable_edit
      enable_multi_edit
      @entry_field.setStringValue @entries[idx].title
      @project_field.setStringValue @entries[idx].project_id.to_s
      @project_description.setStringValue @entries[idx].project_description.to_s
      @customer_field.setStringValue @entries[idx].customer_name

    else
      disable_edit
      disable_multi_edit
    end

  end

  def enable_multi_edit
    @button_multi_delete.setEnabled true
  end

  def disable_multi_edit
    @button_multi_delete.setEnabled false
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
    when 'created_at'
      text_field.stringValue = record.created_at
    when 'entry'
      text_field.stringValue = record.title
    when 'customer'
      text_field.stringValue = record.customer_name
    when 'project'
      text_field.stringValue = record.project_id.to_s
    when 'activity_time'
      text_field.stringValue = record.created_at
    when 'activity_date'
      text_field.stringValue = record.created_at
    end

    return text_field
  end

  def tableView(aTableView, sortDescriptorsDidChange:oldDescriptors)

    case aTableView.sortDescriptors[0].key
    when 'created_at'
      @sorting_column = :created_at
    when 'entry'
      @sorting_column = :title
    when 'customer'
      @sorting_column = :customer_id
    when 'project'
      @sorting_column = :project_id
    end

    @sorting_ascending = aTableView.sortDescriptors[0].ascending
    populate
    @table_view.reloadData
  end

end
