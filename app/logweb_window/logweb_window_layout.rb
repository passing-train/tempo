class LogwebWindowLayout < MK::WindowLayout
  PREFS_WINDOW_IDENTIFIER = 'PREFSWINDOW'

  def layout
      frame from_center(size:[580, 520])
      title "Tempo Time Log"

      add NSButton, :button_close
      add NSButton, :button_print

      @web_view = WebView.alloc.initWithFrame(NSMakeRect(0, 0, 480, 360))
      @web_view.setAutoresizingMask(NSViewMinXMargin|
                                    NSViewMaxXMargin|
                                    NSViewMinYMargin|
                                    NSViewMaxYMargin|
                                    NSViewWidthSizable|
                                    NSViewHeightSizable)

      add @web_view, :web_view do
        constraints do
          top.equals(:superview, :top)
          right.equals(:superview, :right)
          left.equals(:superview, :left)
          bottom.equals(:superview, :bottom).minus 60
        end
      end
  end

  def button_close_style
    bezel_style NSRoundedBezelStyle
    key_equivalent "\r"

    constraints do
      width 100
      height 20
      right.equals(:superview, :right).minus(20)
      bottom.equals(:superview, :bottom).minus(20)
    end

    title "Close"

  end

  def button_print_style
    bezel_style NSRoundedBezelStyle
    key_equivalent "\p"

    constraints do
      width 100
      height 20
      right.equals(:button_close, :left).minus(20)
      bottom.equals(:superview, :bottom).minus(20)
    end

    title "Print"

  end

  private


end
