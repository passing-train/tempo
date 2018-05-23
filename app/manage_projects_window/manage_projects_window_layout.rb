class ManageProjectsWindowLayout < MK::WindowLayout

  def layout
    frame from_center(size:[700, 550])
    title "Wassup: Projects"

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

    add NSTextField, :lbl_description_field
    add NSTextField, :lbl_project_id_field

    add NSTextField, :description_field
    add NSTextField, :project_id_field

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
    configure_as_label_with_title "Project ID"

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
      top.equals(:lbl_description_field, :bottom).plus 10
    end
  end

  def button_update_style
    key_equivalent "\r"
    bezel_style NSRoundedBezelStyle

    constraints do
      width 80
      height 20
      left.equals(:project_id_field, :left)
      top.equals(:description_field, :bottom).plus 20
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
      top.equals(:description_field, :bottom).plus 20
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
      top.equals(:description_field, :bottom).plus 20
    end

    title "cancel"
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
      width 200
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('project_description') do
      title 'Description'
      min_width 120
      width 200
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
