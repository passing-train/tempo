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

  def update_webview

    temp_file = NSApp.delegate.export.create_markdown_file

    content = NSString.stringWithContentsOfFile(temp_file, encoding:NSUTF8StringEncoding, error:nil)

    parser = MarkdownIt::Parser.new({ html: true, linkify: true, typographer: true })
    body = parser.render(content)

    css = NSBundle.mainBundle.URLForResource("github-markdown", withExtension:"css")

    header = '<html><head><link rel="stylesheet" href="'+css.absoluteString+'"></head><body class="markdown-body">'
    footer = '</body></html>'

    @web_view.mainFrame.loadHTMLString(header+body+footer, baseURL:NSBundle.mainBundle.bundleURL)
  end

  def closeWindow(sender)
    window.close
  end

  def printContent(sender)
    printInfo = NSPrintInfo.sharedPrintInfo
    printInfo.setTopMargin 0.5
    printInfo.setRightMargin 0.5
    printOperation = @web_view.mainFrame.frameView.printOperationWithPrintInfo printInfo
    printOperation.runOperation
  end
end
