class ListFlatEntriesWindowLayout < ManageWindowLayoutPrototype

  def layout
    frame from_center(size:[1120, 650])
    title "Tempo FLat Entries List"

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


    add NSTextField, :lbl_search_field
    add NSTextField, :search_field

    add NSTextField, :lbl_fltr_customer_field
    add NSTextField, :fltr_customer_field

    add NSTextField, :lbl_entry_field
    add NSTextField, :lbl_customer_field
    add NSTextField, :lbl_project_field
    add NSTextField, :project_description

#  add NSTextField, :lbl_no_export
#  add NSButton, :check_no_export

#  add NSTextField, :lbl_sticky
#  add NSButton, :check_sticky

    add NSTextField, :entry_field

    @customer_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @customer_field.awakeFromNib
    @customer_field.popOverWidth = 150.0
    @customer_field.wu_identifier = 'customer'
    add @customer_field, :customer_field

    add NSTextField, :project_field
    @project_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @project_field.awakeFromNib
    @project_field.popOverWidth = 150.0
    @project_field.wu_identifier = 'project'
    add @project_field, :project_field

    add NSButton, :button_update
    add NSButton, :button_delete
    add NSButton, :button_cancel

    add NSButton, :button_multi_delete
#  add NSButton, :button_multi_skip_export
#  add NSButton, :button_multi_in_export
#  add NSButton, :button_multi_sticky
#  add NSButton, :button_multi_not_sticky


   add NSTextField, :lbl_addextratime_field
   add NSTextField, :addextratime_field
    add NSButton, :button_divideextra
    add NSButton, :button_lastdayextra

  end

  def outer_view_style
    has_vertical_scroller true
    constraints do
      top.equals(:superview, :top).plus 30
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

  def project_description_style
    configure_as_read_only_text "xxx"
    tag 3

    constraints do
      width 243
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:project_field, :bottom).plus 2
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

#def lbl_sticky_style
#  configure_as_label_with_title('Sticky (never delete)')

#  constraints do
#    width 220
#    height 20
#    left.equals(:check_sticky, :right).plus 10
#    top.equals(:project_field, :bottom).plus(35)
#  end
#end

#def check_sticky_style
#  tag 4
#  button_type NSSwitchButton
#  bezel_style 0
#  title ''

#  constraints do
#    width 20
#    height 20
#    left.equals(:project_field, :left)
#    top.equals(:project_field, :bottom).plus 35
#  end
#end

#def lbl_no_export_style
#  configure_as_label_with_title('Skip in export')

#  constraints do
#    width 100
#    height 20
#    left.equals(:check_no_export, :right).plus 10
#    top.equals(:lbl_sticky, :bottom).plus(10)
#  end
#end

#def check_no_export_style
#  tag 4
#  button_type NSSwitchButton
#  bezel_style 0
#  title ''

#  constraints do
#    width 20
#    height 20
#    left.equals(:project_field, :left)
#    top.equals(:lbl_sticky, :bottom).plus 10
#  end
#end


  def button_update_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:project_field, :left)
      top.equals(:project_field, :bottom).plus 20
    end

    title "update"
  end

  def button_delete_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:button_update, :right).plus 10
      top.equals(:project_field, :bottom).plus 20
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
      top.equals(:project_field, :bottom).plus 20
    end

    title "cancel"
  end

  def lbl_addextratime_field_style
    configure_as_label_with_title "Add or remove time in minutes"

    constraints do
      width 200
      height 25
      left.equals(:superview, :right).minus 278
      top.equals(:superview, :top).plus 360
    end
  end

 def addextratime_field_style
   configure_as_textinput_with_value ""
   tag 4

   constraints do
     width 90
     height 25
     left.equals(:superview, :right).minus 278
     top.equals(:lbl_addextratime_field, :bottom).plus 1
   end
 end

 def button_lastdayextra_style
   key_equivalent "\r"
   bezel_style NSRoundedBezelStyle

   constraints do
     width 120
     height 20
     left.equals(:superview, :right).minus 278
     top.equals(:addextratime_field, :bottom).plus 10
   end

   title "add to last date"
 end


  def lbl_search_field_style
    configure_as_label_with_title "filter entries"

    constraints do
      width 80
      height 25
      left.equals(:superview, :left).plus 10
      top.equals(:superview, :top).plus 5
    end
  end

  def search_field_style
    configure_as_textinput_with_value ""
    tag 4

    constraints do
      width 100
      height 20
      left.equals(:lbl_search_field, :right).plus 10
      top.equals(:superview, :top).plus 5
    end
  end

  def lbl_fltr_customer_field_style
    configure_as_label_with_title "filter customer id"

    constraints do
      width 120
      height 25
      left.equals(:search_field, :right).plus 10
      top.equals(:superview, :top).plus 5
    end
  end

  def fltr_customer_field_style
    configure_as_textinput_with_value ""
    tag 4

    constraints do
      width 100
      height 20
      left.equals(:lbl_fltr_customer_field, :right).plus 10
      top.equals(:superview, :top).plus 5
    end
  end


#def button_divideextra_style
#  key_equivalent "\r"
#  bezel_style NSRoundedBezelStyle

#  constraints do
#    width 120
#    height 20
#    left.equals(:superview, :right).minus 153
#    top.equals(:superview, :top).plus 368
#  end

#  title "equally devide"
#end

  def button_multi_delete_style
    key_equivalent "\m"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 120
      height 20
      left.equals(:button_update, :left)
      top.equals(:button_lastdayextra, :bottom).plus 40
    end

    title "delete selected"
  end


  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    add_column('created_at') do
      title 'Create at'
      min_width 202
      width 300
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('entry') do
      title 'Entry'
      min_width 202
      width 300
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('customer') do
      title 'Customer'
      min_width 100
      width 130
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('project') do
      title 'Project'
      min_width 100
      width 110
      resizing_mask NSTableColumnUserResizingMask
    end

#    add_column('activity_time') do
#      title 'activity time'
#      min_width 70
#      width 150
#      resizing_mask NSTableColumnUserResizingMask
#    end
#
#    add_column('activity_date') do
#      title 'Activity date'
#      min_width 70
#      width 150
#      resizing_mask NSTableColumnUserResizingMask
#    end

  end

end
