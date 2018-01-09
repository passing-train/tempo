class ListEntriesWindowController < NSWindowController

  include CDQ
  def layout
    @layout ||= ListEntriesWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @title = 'NSTableView'
      @layout = layout

      populateEntries
      p @entries

      @button_update = @layout.get(:button_update)
      @button_update.target = self
      @button_update.action = 'update:'

      @table_view = @layout.get(:table_view)
      @table_view.delegate = self
      @table_view.dataSource = self
      @entry_field = @layout.get(:entry_field)
      @project_field = @layout.get(:project_field)
      @customer_field = @layout.get(:customer_field)

      @last_selected_row = nil
    end
  end


  def populateEntries
    entries = Entry.sort_by(:title).map(&:title).uniq

    @entries = []

    #p entries
    entries.each do |e|
      @entries << Entry.where(:title).eq(e).first
    end

  end

  def update sender
    @last_selected_row = @table_view.selectedRow
    p @entries[@last_selected_row].title
    Entry.where(:title).eq(@entries[@last_selected_row].title).each do |e|
      e.title = @entry_field.stringValue.to_s
      e.project_id = @project_field.stringValue.to_s
      e.customer_id = @customer_field.stringValue.to_i
    end
    cdq.save
    populateEntries
    @table_view.reloadData
    disable_edit

    indexSet = NSIndexSet.indexSetWithIndex @last_selected_row
    @table_view.selectRowIndexes(indexSet, byExtendingSelection:false)
    self.window.makeFirstResponder @table_view
  end

  def disable_edit
      @entry_field.setStringValue ''
      @project_field.setStringValue ''
      @customer_field.setStringValue ''

      @entry_field.setEditable false
      @project_field.setEditable false
      @customer_field.setEditable false

      @button_update.setEnabled false
  end

  def enable_edit
      @entry_field.setEditable true
      @project_field.setEditable true
      @customer_field.setEditable true
      @button_update.setEnabled true
  end

  def tableViewSelectionDidChange sender
    idx = @table_view.selectedRow
    p idx
    if idx == -1
      disable_edit
    else
      enable_edit
      @entry_field.setStringValue @entries[idx].title
      @project_field.setStringValue @entries[idx].project_id.to_s
      @customer_field.setStringValue @entries[idx].customer_id.to_s
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
      text_field.stringValue = record.customer_id.to_s
    when 'project'
      text_field.stringValue = record.project_id.to_s
    end

    return text_field
  end

#  def tableViewColumnDidResize(notification)
#  end

end
