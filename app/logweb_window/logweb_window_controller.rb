class LogwebWindowController < NSWindowController

  def layout
    @layout ||= LogwebWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window

      @button_close = @layout.get(:button_close)
      @button_close.target = self
      @button_close.action = 'closeWindow:'

      @web_view = @layout.get(:web_view)
      @web_view.setFrameLoadDelegate self

    end
  end

  def update_webview content
    @web_view.mainFrame.loadHTMLString(content, baseURL:NSBundle.mainBundle.bundleURL)
  end

  def closeWindow(sender)
    window.close
  end
end
