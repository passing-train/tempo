class ManageCustomersWindowController < ManageWindowControllerPrototype

  def layout
    @layout ||= ManageCustomersWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @layout = layout

      populate

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

      @name_field = @layout.get(:name_field)
      @customer_id_field = @layout.get(:customer_id_field)

      @last_selected_row = nil
      @button_mode = 'add'
      disable_edit
    end
  end

  def populate
    @customers = Customer.sort_by(:name)
  end

  def cancel sender
    disable_edit
    @table_view.deselectAll sender
    self.window.makeFirstResponder @table_view
  end

  def update sender
    if @button_mode == 'add'
      Customer.create(name: @name_field.stringValue.to_s, customer_id: @customer_id_field.stringValue.to_i)
    else
      @last_selected_row = @table_view.selectedRow

      Customer.where(:customer_id).eq(@customers[@last_selected_row].customer_id).each do |e|
        e.name = @name_field.stringValue.to_s
        e.customer_id = @customer_id_field.stringValue.to_i
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



  def delete sender

    @last_selected_row = @table_view.selectedRow

    Customer.where(:customer_id).eq(@customers[@last_selected_row].customer_id).each do |e|
      e.destroy
    end

    cdq.save

    call_reload_all_windows
    disable_edit

    self.window.makeFirstResponder @table_view
  end

  def disable_edit
      @button_mode = 'add'
      @name_field.setStringValue ''
      @customer_id_field.setStringValue ''
      @button_update.setTitle 'Add customer'
      @button_delete.setEnabled false
      @button_cancel.setEnabled false
  end

  def enable_edit
      @button_mode = 'edit'
      @button_update.setTitle 'Edit customer'
      @button_delete.setEnabled true
      @button_cancel.setEnabled true
  end

  def tableViewSelectionDidChange sender
    idx = @table_view.selectedRow
    if idx == -1
      disable_edit
    else
      enable_edit
      @name_field.setStringValue @customers[idx].name
      @customer_id_field.setStringValue @customers[idx].customer_id.to_s
    end
  end

  def numberOfRowsInTableView(table_view)
    @customers.length
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

    record = @customers[rowidx]

    case column.identifier
    when 'name'
      text_field.stringValue = record.name
    when 'customer_id'
      text_field.stringValue = record.customer_id.to_s
    end

    return text_field
  end

end
