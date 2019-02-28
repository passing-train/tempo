class ManageCustomersWindowLayout < ManageWindowLayoutPrototype

  def layout
    frame from_center(size:[700, 550])
    title "Tempo: Customers"

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

    add NSTextField, :lbl_name_field
    add NSTextField, :lbl_customer_id_field

    add NSTextField, :name_field
    add NSTextField, :customer_id_field

    add NSButton, :button_update
    add NSButton, :button_delete
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

  def lbl_name_field_style
    configure_as_label_with_title "Name"
    constraints do
      width 300
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 25
    end
  end

  def name_field_style
    configure_as_textinput_with_value ""
    tag 1

    constraints do
      width 243
      height 46
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 46
    end
  end

  def lbl_customer_id_field_style
    configure_as_label_with_title "Customer ID"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 112
    end
  end

  def customer_id_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 134
    end
  end

  def button_update_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:customer_id_field, :left)
      top.equals(:customer_id_field, :bottom).plus 20
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
      top.equals(:customer_id_field, :bottom).plus 20
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
      top.equals(:customer_id_field, :bottom).plus 20
    end

    title "cancel"
  end

  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    add_column('name') do
      title 'Name'
      min_width 100
      width 130
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('customer_id') do
      title 'Customer ID'
      min_width 100
      width 130
      resizing_mask NSTableColumnUserResizingMask
    end

  end

end
