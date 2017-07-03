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

      @button_print = @layout.get(:button_print)
      @button_print.target = self
      @button_print.action = 'printContent:'


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

  def printContent(sender)

    printInfo = NSPrintInfo.sharedPrintInfo

    # This is your chance to modify printInfo if you need to change 
    # the page orientation, margins, etc
    #[printInfo setOrientation:NSLandscapeOrientation]
    #
#    printInfo.setBottomMargin 0.0
#    printInfo.setLeftMargin 0.0
    printInfo.setTopMargin 0.5
    printInfo.setRightMargin 0.5

    printOperation = @web_view.mainFrame.frameView.printOperationWithPrintInfo printInfo

    #// Open the print dialog
    printOperation.runOperation

#/ If you want your print window to appear as a sheet instead of a popup,
#// use this method instead of -[runOperation]
#printOperation.runOperationModalForWindow:yourWindow
#                                  delegate:self 
#                            didRunSelector:@selector(printDidRun)
#                               contextInfo:nil];
  end

end
