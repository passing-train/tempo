class AskWindowLayout < MK::WindowLayout
  ASK_WINDOW_IDENTIFIER = 'ASKWINDOW'

  def layout
    frame from_center(size:[500, 250])
    title "Wassup"
    style_mask (style_mask & ~NSWindowStyleMaskMiniaturizable & ~NSWindowStyleMaskResizable & ~NSWindowStyleMaskClosable)

    add NSButton, :button_cancel
    add NSButton, :button_ok
#    add NSTextField, :task_title
    add NSTextField, :task_title_label

    add NSTextField, :lbl_time_today_field
    add NSTextField, :lbl_total_time_field
    add NSTextField, :lbl_customer_field
    add NSTextField, :lbl_project_field

    add NSTextField, :time_today_field
    add NSTextField, :total_time_field
    add NSTextField, :customer_field
    add NSTextField, :project_field

    @appIcon = NSImage.imageNamed 'tempo-icon-128'
    @appIconView = NSImageView.imageViewWithImage @appIcon
    add @appIconView, :app_icon
    #
    #tempo-icon-128.png

    @input_field = WuAutoCompleteTextField.alloc.initWithFrame(NSMakeRect(0, 0, 300, 24))
    @input_field.awakeFromNib
    add @input_field, :task_title

  end

  def app_icon_style

    constraints do
      #width 400
      height 60
      width 60
      left.equals(:superview, :left).plus(20)
      top.equals(:superview, :top).plus(15)
    end
  end

  def task_title_label_style
    configure_as_label_with_title('Whats going on?')

    constraints do
      height 20
      left.equals(:superview, :left).plus(90)
      right.equals(:superview, :right).minus(20)
      top.equals(:superview, :top).plus(15)
    end
  end

  def task_title_style
    configure_as_textinput_with_value "some val"
    tag 1

    constraints do
      height 25
      left.equals(:superview, :left).plus(90)
      right.equals(:superview, :right).minus(20)
      top.equals(:task_title_label, :bottom).plus(10)
    end
  end

  def lbl_time_today_field_style
    configure_as_mini_label_with_title "Time today:"

    constraints do
      height 16
      left.equals(:task_title, :left)
      top.equals(:task_title, :bottom).plus(15)
    end
  end

  def lbl_total_time_field_style
    configure_as_mini_label_with_title "Total time:"

    constraints do
      height 16
      left.equals(:lbl_time_today_field, :left)
      top.equals(:lbl_time_today_field, :bottom).plus(5)
    end
  end

  def lbl_customer_field_style
    configure_as_mini_label_with_title "Customer:"

    constraints do
      height 16
      right.equals(:lbl_total_time_field, :right)
      top.equals(:lbl_total_time_field, :bottom).plus(5)
    end
  end

  def lbl_project_field_style
    configure_as_mini_label_with_title "Project:"

    constraints do
      height 16
      right.equals(:lbl_customer_field, :right)
      top.equals(:lbl_customer_field, :bottom).plus(5)
    end
  end

  def time_today_field_style
    configure_as_regular_label_with_title ""

    constraints do
      height 16
      left.equals(:lbl_time_today_field, :right).plus 5
      top.equals(:lbl_time_today_field, :top).minus 3
    end
  end

  def total_time_field_style
    configure_as_regular_label_with_title ""

    constraints do
      height 16
      left.equals(:lbl_total_time_field, :right).plus 5
      top.equals(:lbl_total_time_field, :top).minus 3
    end
  end

  def customer_field_style
    configure_as_regular_label_with_title ""

    constraints do
      height 16
      left.equals(:lbl_customer_field, :right).plus 5
      top.equals(:lbl_customer_field, :top).minus 3
    end
  end

  def project_field_style
    configure_as_regular_label_with_title ""

    constraints do
      height 16
      left.equals(:lbl_project_field, :right).plus 5
      top.equals(:lbl_project_field, :top).minus 3
    end
  end

  def button_cancel_style
    bezel_style NSRoundedBezelStyle
    key_equivalent "\e"

    constraints do
      width 100
      height 20
      right.equals(:button_ok, :left).minus(10)
      bottom.equals(:superview, :bottom).minus(20)
    end

    title "Cancel"

  end

  def button_ok_style
    bezel_style NSRoundedBezelStyle
    key_equivalent "\r"

    constraints do
      width 100
      height 20
      right.equals(:superview, :right).minus(20)
      bottom.equals(:superview, :bottom).minus(20)
    end

    title "OK"

  end

  private

  def configure_as_textinput_with_value value
    editable true
    selectable true
    bordered true
    bezeled true

    string_value value
  end

  def configure_as_mini_label_with_title title
    boldFontName = NSFont.boldSystemFontOfSize(10.0)
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

  def configure_as_regular_label_with_title title
    fontName = NSFont.systemFontOfSize(14.0)
    str = NSMutableAttributedString.alloc.initWithString(title)
    str.addAttribute(NSFontAttributeName, value:fontName, range:NSMakeRange(0, str.length))
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
