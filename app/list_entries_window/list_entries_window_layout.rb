class ListEntriesWindowLayout < MK::WindowLayout

  def layout
    frame from_center(size:[590, 550])
    title "Wassup List"

    add NSScrollView, :outer_view do
      document_view add NSTableView, :table_view
    end

    add NSTextField, :lbl_entry_field
    add NSTextField, :lbl_customer_field
    add NSTextField, :lbl_project_field

    add NSTextField, :entry_field
    add NSTextField, :customer_field
    add NSTextField, :project_field

    add NSButton, :button_update
  end

  def outer_view_style
    has_vertical_scroller true
    constraints do
      top.equals(:superview, :top)
      right.equals(:superview, :right)
      left.equals(:superview, :left)
      bottom.equals(:superview, :bottom).minus 70
    end
  end

  def button_update_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 100
      height 20
      left.equals(:project_field, :right).plus(20)
      bottom.equals(:superview, :bottom).minus(22)
    end

    title "update entry"
  end

  def entry_field_style
    configure_as_textinput_with_value ""
    tag 1

    constraints do
      width 300
      height 25
      left.equals(:superview, :left).plus(10)
      bottom.equals(:superview, :bottom).minus(20)
    end
  end

  def lbl_entry_field_style
    configure_as_label_with_title "entry"
    constraints do
      width 300
      height 25
      left.equals(:superview, :left).plus(10)
      bottom.equals(:superview, :bottom).minus(40)
    end
  end

  def customer_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 50
      height 25
      left.equals(:entry_field, :right).plus(10)
      bottom.equals(:superview, :bottom).minus(20)
    end
  end

  def lbl_customer_field_style
    configure_as_label_with_title "cst"

    constraints do
      width 50
      height 25
      left.equals(:entry_field, :right).plus(10)
      bottom.equals(:superview, :bottom).minus(40)
    end
  end

  def project_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 80
      height 25
      left.equals(:customer_field, :right).plus(10)
      bottom.equals(:superview, :bottom).minus(20)
    end
  end

  def lbl_project_field_style
    configure_as_label_with_title "project"

    constraints do
      width 80
      height 25
      left.equals(:customer_field, :right).plus(10)
      bottom.equals(:superview, :bottom).minus(40)
    end
  end

  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    add_column('entry') do
      title 'Entry'
      min_width 102
      width 300
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('customer') do
      title 'Customer'
      min_width 50
      width parent_bounds.size.width - 170
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('project') do
      title 'Project'
      min_width 102
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
