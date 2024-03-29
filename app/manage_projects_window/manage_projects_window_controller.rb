class ManageProjectsWindowController < ManageWindowControllerPrototype

  def layout
    @layout ||= ManageProjectsWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @layout = layout

      @sorting_column = :project_description
      @sorting_ascending = true

      populate

      @button_multi_delete = @layout.get(:button_multi_delete)
      @button_multi_delete.target = self
      @button_multi_delete.action = 'multi_delete:'

      @button_update = @layout.get(:button_update)
      @button_update.target = self
      @button_update.action = 'update:'

      @button_delete = @layout.get(:button_delete)
      @button_delete.target = self
      @button_delete.action = 'delete:'

      @button_cancel = @layout.get(:button_cancel)
      @button_cancel.target = self
      @button_cancel.action = 'cancel:'

      @table_view = @layout.get(:table_view)
      @table_view.delegate = self
      @table_view.dataSource = self
      @table_view.allowsMultipleSelection = true

      @description_field = @layout.get(:description_field)
      @project_id_field = @layout.get(:project_id_field)

      @customer_field = @layout.get(:customer_field)
      @customer_field.tableViewDelegate = self

      init_sort_descriptors

      @last_selected_row = nil
      @button_mode = 'add'
      disable_edit
    end
  end

  def populate
    if @sorting_ascending
      order = :ascending
    else
      order = :descending
    end

    @projects = Project.sort_by(@sorting_column, order: order)
  end

  def cancel sender
    disable_edit
    @table_view.deselectAll sender
    self.window.makeFirstResponder @table_view
  end

  def keyUp(event)
    case event.keyCode
    when 36, 48, 51, 49 # return, tab, space
      @customer_field.autoCompletePopover.close()
    end
  end

  def textField(textField, completions:somecompletions, forPartialWordRange:partialWordRange, indexOfSelectedItem:theIndexOfSelectedItem)
    if textField.wu_identifier == 'customer'
      matches = Customer.where(:name).contains(textField.stringValue,NSCaseInsensitivePredicateOption).map(&:name).uniq
    end

    matches
  end


  def update sender

    customer = Customer.where(:name).eq(@customer_field.stringValue.to_s).first


    if @button_mode == 'add'

      if customer
        Project.create(project_id: @project_id_field.stringValue.to_s, project_description: @description_field.stringValue.to_s, customer_id: customer.customer_id.to_i)
      else
        Project.create(project_id: @project_id_field.stringValue.to_s, project_description: @description_field.stringValue.to_s)
      end

    else
      @last_selected_row = @table_view.selectedRow

      Project.where(:project_id).eq(@projects[@last_selected_row].project_id).each do |e|

        e.project_description = @description_field.stringValue.to_s
        e.project_id = @project_id_field.stringValue.to_s
        if customer
          e.customer_id = customer.customer_id.to_i
        end
      end
    end

    cdq.save
    call_reload_all_windows
    disable_edit

    if @button_mode == 'edit'
      indexSet = NSIndexSet.indexSetWithIndex @last_selected_row
      @table_view.selectRowIndexes(indexSet, byExtendingSelection:false)
    end

    self.window.makeFirstResponder @table_view

  end

  def enable_multi_edit
    @button_multi_delete.setEnabled true
  end

  def disable_multi_edit
    @button_multi_delete.setEnabled false
  end

  def multi_delete sender

    text =  "Are you sure you want to delete these " + @table_view.selectedRowIndexes.count.to_s + " projects?"

    if alert_confirm("Delete projects",text)
      currentIndex = @table_view.selectedRowIndexes.firstIndex
      while currentIndex != NSNotFound do

        Project.where(:project_id).eq(@projects[currentIndex].project_id).each do |e|
          e.destroy
        end

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

    Project.where(:project_id).eq(@projects[@last_selected_row].project_id).each do |e|
      e.destroy
    end

    cdq.save
    call_reload_all_windows
    disable_edit

    self.window.makeFirstResponder @table_view
  end

  def disable_edit
      @button_mode = 'add'
      @description_field.setStringValue ''
      @customer_field.setStringValue ''
      @project_id_field.setStringValue ''
      @button_update.setTitle 'Add project'
      @button_delete.setEnabled false
      @button_cancel.setEnabled false
  end

  def enable_edit
      @button_mode = 'edit'
      @button_update.setTitle 'Edit project'
      @button_delete.setEnabled true
      @button_cancel.setEnabled true
  end

  def tableViewSelectionDidChange sender

    if @table_view.selectedRowIndexes.count > 0

      disable_multi_edit
      idx = @table_view.selectedRow
      enable_edit
      enable_multi_edit

      enable_edit
      @customer_field.setStringValue @projects[idx].customer_name
      if @projects[idx].project_description
        @description_field.setStringValue @projects[idx].project_description
      else
        @description_field.setStringValue ''
      end
      @project_id_field.setStringValue @projects[idx].project_id.to_s

    else
      disable_edit
      disable_multi_edit
    end
  end

  def numberOfRowsInTableView(table_view)
    @projects.length
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

    record = @projects[rowidx]

    case column.identifier
    when 'project_id'
      text_field.stringValue = record.project_id.to_s
    when 'customer'
      text_field.stringValue = record.customer_name
    when 'entries_amount'
      text_field.stringValue = record.entries_amount
    when 'project_description'
      if record.project_description
        text_field.stringValue = record.project_description
      else
        text_field.stringValue = ''
      end
    end

    return text_field
  end

  def init_sort_descriptors
      descriptorProjectId = NSSortDescriptor.sortDescriptorWithKey('project_id' , ascending:true, selector:'compare:')
      @table_view.tableColumns[0].sortDescriptorPrototype = descriptorProjectId

      descriptorProjectDescription = NSSortDescriptor.sortDescriptorWithKey('project_description' , ascending:true, selector:'compare:')
      @table_view.tableColumns[1].sortDescriptorPrototype = descriptorProjectDescription

      descriptorCustomer = NSSortDescriptor.sortDescriptorWithKey('customer' , ascending:true, selector:'compare:')
      @table_view.tableColumns[2].sortDescriptorPrototype = descriptorCustomer
  end


  def tableView(aTableView, sortDescriptorsDidChange:oldDescriptors)

    case aTableView.sortDescriptors[0].key
    when 'project_description'
      @sorting_column = :project_description
    when 'customer'
      @sorting_column = :customer_id
    when 'project_id'
      @sorting_column = :project_id
    end

    @sorting_ascending = aTableView.sortDescriptors[0].ascending
    populate
    @table_view.reloadData
  end



end
