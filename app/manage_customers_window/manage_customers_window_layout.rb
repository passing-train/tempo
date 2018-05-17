class ManageCustomersWindowLayout < MK::WindowLayout

  def layout
    frame from_center(size:[700, 550])
    title "Wassup: Customers"

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
      width 120
      height 20
      left.equals(:superview, :right).minus 153
      top.equals(:superview, :top).plus 238
    end

    title "add customer"
  end

  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    add_column('name') do
      title 'Name'
      min_width 102
      width 300
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('customer_id') do
      title 'Customer ID'
      min_width 50
      width parent_bounds.size.width - 170
      resizing_mask NSTableColumnUserResizingMask
    end

  end

  def configure_as_textinput_with_value value
    editable true
    selectable true
    bordered true
    bezeled true

    string_value value
  end

  def configure_as_label_with_title title
    boldFontName = NSFont.boldSystemFontOfSize(13.0)
    str = NSMutableAttributedString.alloc.initWithString(title)
    str.addAttribute(NSFontAttributeName, value:boldFontName, range:NSMakeRange(0, str.length))
    attributed_string_value str

    editable false
    selectable false
    bordered false
    bezeled false

    cell do
      scrollable false
      drawsBackground false
    end
  end

end
