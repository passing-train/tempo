class ListEntriesWindowLayout < MK::WindowLayout

  def layout
    frame from_center(size:[990, 550])
    title "Wassup List"

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

    add NSTextField, :lbl_entry_field
    add NSTextField, :lbl_customer_field
    add NSTextField, :lbl_project_field

    add NSTextField, :entry_field

    @customer_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @customer_field.awakeFromNib
    @customer_field.popOverWidth = 150.0
    @customer_field.wu_identifier = 'customer'
    add @customer_field, :customer_field

#    add NSTextField, :project_field
    @project_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @project_field.awakeFromNib
    @project_field.popOverWidth = 150.0
    @project_field.wu_identifier = 'project'
    add @project_field, :project_field

    add NSButton, :button_update

    add NSTextField, :lbl_addextratime_field
    add NSTextField, :addextratime_field
#    add NSButton, :button_divideextra
    add NSButton, :button_lastdayextra

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

  def lbl_entry_field_style
    configure_as_label_with_title "Entry"
    constraints do
      width 300
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 25
    end
  end

  def entry_field_style
    configure_as_textinput_with_value ""
    tag 1

    constraints do
      width 243
      height 46
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 46
    end
  end

  def lbl_customer_field_style
    configure_as_label_with_title "Customer"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 112
    end
  end

  def customer_field_style
    configure_as_textinput_with_value ""
    tag 2

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 134
    end
  end

  def lbl_project_field_style
    configure_as_label_with_title "Project"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 177
    end
  end

  def project_field_style
    configure_as_textinput_with_value ""
    tag 3

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 196
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

    title "update entry"
  end


  def lbl_addextratime_field_style
    configure_as_label_with_title "Add extra time"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 310
    end
  end

  def addextratime_field_style
    configure_as_textinput_with_value ""
    tag 4

    constraints do
      width 90
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 334
    end
  end


  def button_divideextra_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 120
      height 20
      left.equals(:superview, :right).minus 153
      top.equals(:superview, :top).plus 368
    end

    title "equally devide"
  end

  def button_lastdayextra_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 120
      height 20
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 368
    end

    title "add to last date"
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

    add_column('total_time') do
      title 'Total time'
      min_width 102
      width parent_bounds.size.width - 170
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('total_day_time') do
      title 'Time today'
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
