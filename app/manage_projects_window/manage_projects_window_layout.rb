class ManageProjectsWindowLayout < ManageWindowLayoutPrototype

  def layout
    frame from_center(size:[700, 550])
    title "Tempo: Projects"

    add NSScrollView, :outer_view do
      document_view add NSTableView, :table_view
    end

    add NSBox, :line do
      box_type NSBoxSeparator
      frame from_bottom(size: [1, '100%'])
      constraints do
        right.equals(:superview, :right).minus 294
      end
    end

    add NSTextField, :lbl_project_id_field
    add NSTextField, :project_id_field

    add NSTextField, :lbl_description_field
    add NSTextField, :description_field

    add NSTextField, :lbl_customer_field

    @customer_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @customer_field.awakeFromNib
    @customer_field.popOverWidth = 150.0
    @customer_field.wu_identifier = 'customer'
    add @customer_field, :customer_field
    #add NSTextField, :customer_field


    add NSButton, :button_update
    add NSButton, :button_delete
    add NSButton, :button_multi_delete
    add NSButton, :button_cancel

  end

  def outer_view_style
    has_vertical_scroller true
    constraints do
      top.equals(:superview, :top)
      right.equals(:superview, :right).minus 295
      left.equals(:superview, :left)
      bottom.equals(:superview, :bottom)
    end
  end

  def lbl_project_id_field_style
    configure_as_label_with_title "Project ID"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 25
    end
  end

  def project_id_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 46
    end
  end

  def lbl_description_field_style
    configure_as_label_with_title "Description"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:project_id_field, :bottom).plus 20
    end
  end

  def description_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 243
      height 46
      left.equals(:superview, :right).minus 278
      top.equals(:lbl_description_field, :bottom)
    end

  end
  def lbl_customer_field_style
    configure_as_label_with_title "Customer"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:description_field, :bottom).plus 20
    end
  end

  def customer_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:lbl_customer_field, :bottom)
    end
  end

  def button_update_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:project_id_field, :left)
      top.equals(:customer_field, :bottom).plus 20
    end

    title "add"
  end

  def button_delete_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:button_update, :right).plus 10
      top.equals(:customer_field, :bottom).plus 20
    end

    title "delete"
  end

  def button_cancel_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:button_delete, :right).plus 10
      top.equals(:customer_field, :bottom).plus 20
    end

    title "cancel"
  end

  def button_multi_delete_style
    key_equivalent "\m"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 120
      height 20
      left.equals(:button_update, :left)
      top.equals(:button_update, :bottom).plus 40
    end

    title "delete selected"
  end

  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    add_column('project_id') do
      title 'Project ID'
      min_width 120
      width 140
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('project_description') do
      title 'Description'
      min_width 120
      width 200
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('customer') do
      title 'Customer'
      min_width 120
      width 120
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('entries_amount') do
      title '# Entries'
      min_width 50
      width 50
      resizing_mask NSTableColumnUserResizingMask
    end

  end

end
