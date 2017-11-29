class AskWindowLayout < MK::WindowLayout
  ASK_WINDOW_IDENTIFIER = 'ASKWINDOW'

  def layout
    frame from_center(size:[424, 150])
    title "Wassup"
    style_mask (style_mask & ~NSWindowStyleMaskMiniaturizable & ~NSWindowStyleMaskResizable & ~NSWindowStyleMaskClosable)

    add NSButton, :button_cancel
    add NSButton, :button_ok
    add NSTextField, :task_title
    add NSTextField, :task_title_label

  end

  def task_title_label_style
    configure_as_label_with_title('Whats going on?')

    constraints do
      width 340
      height 20
      left.equals(:superview, :left).plus(20)
      top.equals(:superview, :top).plus(15)
    end
  end

  def task_title_style
    configure_as_textinput_with_value "some val"
    tag 1

    constraints do
      width 384
      height 25
      left.equals(:superview, :left).plus(20)
      top.equals(:task_title_label, :bottom).plus(10)
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

  def configure_as_label_with_title title
    boldFontName = NSFont.boldSystemFontOfSize(13.0)
    str = NSMutableAttributedString.alloc.initWithString(title)
    str.addAttribute(NSFontAttributeName, value:boldFontName, range:NSMakeRange(0, str.length))
    attributed_string_value str

    editable false
    selectable false
    bordered false
    bezeled false
    #string_value title

    cell do
      #alignment NSRightTextAlignment
      scrollable false
      drawsBackground false
    end
  end

end
