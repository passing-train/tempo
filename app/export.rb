class Export

  def init
    application_support = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).first
    @snippet_path = File.join(application_support, 'wassup', 'snippets')
    Motion::FileUtils.mkdir_p(@snippet_path) unless File.exist?(@snippet_path)
    setDateFormats
    self
  end

  def setDateFormats
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"
    @dayFormat = NSDateFormatter.new
    @dayFormat.setDateFormat "EEEE"
    @timeFormat = NSDateFormatter.new
    @timeFormat.setDateFormat " HH:mm"
  end


  def export_csv_log
    rows = []
    Entry.all.sort_by('created_at').each do |entry|
      rows << [entry.created_at, entry.title]
    end

    panel = NSSavePanel.savePanel

    panel.setNameFieldStringValue "time-entries.csv"

    panel.beginWithCompletionHandler(
      lambda do | result |
        if result == NSFileHandlingPanelOKButton
          rows.to_csv.writeToFile(panel.URL, atomically:true, encoding:NSUTF8StringEncoding, error:nil)
        end
      end
    )
  end

  def create_markdown_file(file = File.join(@snippet_path, 'snippets_temp.md'))

#    file = File.join(@snippet_path, 'snippets_temp.md') if file == nil

    Motion::FileUtils.rm(file) if File.exist?(file)

    snippets_md ||= open(file, 'ab')
    snippets_md << "# Time report\n"
    snippets_md << "\n"
    snippets_md << "| date       | day       | time     | activity                                 |\n"
    snippets_md << "|------------|-----------|----------|------------------------------------------|\n"

    Entry.all.sort_by('created_at').each do |entry|

      date = @dateFormat.stringFromDate entry.created_at
      day = @dayFormat.stringFromDate entry.created_at
      time = @timeFormat.stringFromDate entry.created_at

      snippets_md << "| #{date} | #{day} | #{time} | #{entry.title}                                  |\n"
    end

    snippets_md.flush

    return file
  end

end
