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

  def interpret_add_key_val(row, keys, key, val)
    if(!keys.kind_of?(Array)||keys.include?(key))
      row[key] = val
    end
    row
  end

  def interpret(keys = nil, last_only = false)
    last_entry = nil
    block_total = 0

    rows = []

    Entry.all.sort_by('created_at').each do |entry|

      row = {}

      if last_entry.nil? || entry.title != last_entry.title || last_entry.last_in_block?
        block_total = 0
      end

      block_total += entry.time_delta

      if entry.last_in_block?
        block_total_display = TimeUtility::format_time_from_seconds block_total
        block_total_seconds = block_total
      else
        block_total_display = ''
        block_total_seconds = 0
      end

      row = interpret_add_key_val(row, keys, 'created_at', entry.created_at)
      row = interpret_add_key_val(row, keys, 'day', @dayFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'date', @dateFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'time', @timeFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'activity', entry.title)
      row = interpret_add_key_val(row, keys, 'time_delta', entry.time_delta)
      row = interpret_add_key_val(row, keys, 'time_spent', block_total_display)
      row = interpret_add_key_val(row, keys, 'last_in_block', entry.last_in_block)

      rows << row if !last_only || entry.last_in_block?

      last_entry = entry

    end

    rows

  end

  def export_csv_log

    rows = interpret


    if rows.length > 0

      rows_arr = []
      rows_arr << rows[0].keys

      rows.each do | row |
        rows_arr << row.values
      end

#      rows_arr = rows.values
#      headers = rows[0].keys
#      rows_arr.unshift(headers)

      panel = NSSavePanel.savePanel
      panel.setNameFieldStringValue "time-entries.csv"
      panel.beginWithCompletionHandler(
        lambda do | result |
          if result == NSFileHandlingPanelOKButton
            rows_arr.to_csv.writeToFile(panel.URL, atomically:true, encoding:NSUTF8StringEncoding, error:nil)
          end
        end
      )

    else
      alert = NSAlert.alloc.init
      alert.setMessageText  "Cannot export"
      alert.setInformativeText "There are not entries."
      alert.addButtonWithTitle "Ok"
      alert.runModal
    end
  end

  def create_markdown_header(title, keys)
    header = "# #{title}\n"
    header += "\n"

    header += "| "
    keys.each do | col |
      header += col + " |"
    end
    header += " \n|"

    keys.each do | col |
      header += "--------|"
    end
    header += " |\n"

  end

  def create_markdown_table_row(keys, row)
    mdrow = "| "
    keys.each do | col |
      mdrow += row[col] + " |"
    end
    mdrow += " \n"
  end


  def create_cumulated_markdown_file(file = File.join(@snippet_path, 'snippets_temp_cum.md'))

    Motion::FileUtils.rm(file) if File.exist?(file)

    handle ||= open(file, 'ab')

    keys = ['date', 'day', 'activity','time_spent']
    handle << create_markdown_header('Time Report', keys)

    rows = interpret(keys, true)

    mp rows

    rows.each do | row |
      handle << create_markdown_table_row(keys,row)
    end

    handle.flush

    file
  end


  def create_markdown_file(file = File.join(@snippet_path, 'snippets_temp.md'))

    Motion::FileUtils.rm(file) if File.exist?(file)

    handle ||= open(file, 'ab')

    keys = ['date', 'day','time', 'activity']
    handle << create_markdown_header('Time Report', keys)

    rows = interpret(keys, false)

    rows.each do | row |
      handle << create_markdown_table_row(keys,row)
    end

    handle.flush

    file
  end

end
