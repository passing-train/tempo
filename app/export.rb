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
    cum_start_time = 0

    rows = []

    i = 0
    Entry.all.sort_by('created_at').each do |entry|

      i += 1

      if block_total == 0 ||  cum_start_time == 0
        cum_start_time = @timeFormat.stringFromDate(entry.created_at)
      end

      if Entry.all.sort_by('created_at')[i]
        day_next_entry = @dateFormat.stringFromDate(Entry.all.sort_by('created_at')[i].created_at)
      else
        day_next_entry = nil
      end

      row = {}

      if last_entry.nil? || entry.title != last_entry.title || last_entry.last_in_block?
        block_total = 0
      end

      ## Voorkom te lange blokken, dan behandelen als een extra stuk
      interval = NSUserDefaults.standardUserDefaults.integerForKey('AskInterval')
      extra_marge = 30
      if entry.time_delta > (interval + 5 + extra_marge) * 60
        block_total += (interval + 5) * 60 + extra_marge
        work_break = true
      else
        work_break = false
        block_total += entry.time_delta
      end

      time_delta_display = TimeUtility::format_time_from_seconds block_total

      # weergeven als nieuwe dag of laatste blok
      if entry.last_in_block? ||
          @dateFormat.stringFromDate(entry.created_at) != day_next_entry ||
          work_break
        block_total_display = TimeUtility::format_time_from_seconds block_total
        block_total_secs = block_total
        block_total = 0
      else
        block_total_display = ''
      end

      row = interpret_add_key_val(row, keys, 'created_at', entry.created_at)
      row = interpret_add_key_val(row, keys, 'day', @dayFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'date', @dateFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'time', @timeFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'time_first_log', cum_start_time)
      row = interpret_add_key_val(row, keys, 'time_last_log', @timeFormat.stringFromDate(entry.created_at))
      row = interpret_add_key_val(row, keys, 'activity', entry.title)
      row = interpret_add_key_val(row, keys, 'time_delta', time_delta_display)
      row = interpret_add_key_val(row, keys, 'time_spent', block_total_display)
      row = interpret_add_key_val(row, keys, 'block_total_secs', block_total_secs)
      row = interpret_add_key_val(row, keys, 'last_in_block', entry.last_in_block)

      if !last_only ||
          entry.last_in_block? ||
          @dateFormat.stringFromDate(entry.created_at) != day_next_entry ||
          work_break ||
          time_delta_display == '00:00'

        rows << row
      end

      last_entry = entry

    end
    rows
  end

  def interpret_day_totals(keys)

    _keys = ['date', 'day', 'activity','time_spent', 'block_total_secs']

    rows = interpret(_keys,true)
    dates = {}
    rows.each do | entry |
      dates[entry['date']] = [] if dates[entry['date']].nil?
      dates[entry['date']] << entry
    end

    dates_with_totals = {}
    dates.each do | date, entries |
      if dates_with_totals[date].nil?
        dates_with_totals[date] = {
          'date'=> date,
          'day' => entries[0]['day'],
          'activities' => {}
        }
      end

      entries.each do | entry|
        if dates_with_totals[date]['activities'][entry['activity']].nil?
          dates_with_totals[date]['activities'][entry['activity']] = 0
        end

        dates_with_totals[date]['activities'][entry['activity']] += entry['block_total_secs'] if entry['block_total_secs']
      end
    end

#    ap dates_with_totals

    flat_activity_totals = []
    dates_with_totals.each do | date, entry |
      entry['activities'].each do | activity, time_spent |
       flat_activity_totals << {'date'=> entry['date'], 'day'=> entry['day'], 'activity' => activity, 'time_spent'=> TimeUtility::format_time_from_seconds(time_spent)}
      end
    end

#    ap flat_activity_totals
    flat_activity_totals
  end

  def export_csv_log

    rows = interpret

    if rows.length > 0

      rows_arr = []
      rows_arr << rows[0].keys

      rows.each do | row |
        rows_arr << row.values
      end

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
      mdrow += row[col].to_s + " |"
    end
    mdrow += " \n"
  end

  def create_cumulated_markdown_file(file = File.join(@snippet_path, 'snippets_temp_cum.md'))

    #interpret_day_totals(['date', 'day', 'activity', 'time_spent'])

    Motion::FileUtils.rm(file) if File.exist?(file)

    handle ||= open(file, 'ab')

    keys = ['date', 'day', 'time_first_log', 'time_last_log', 'activity','time_spent', 'block_total_secs']
    handle << create_markdown_header('Time Report', keys)

    rows = interpret(keys, true)

    rows.each do | row |
      handle << create_markdown_table_row(keys,row)
    end

    handle.flush

    file

  end

  def create_cumulated_daytotals_markdown_file(file = File.join(@snippet_path, 'snippets_temp_cumdaytotals.md'))

    Motion::FileUtils.rm(file) if File.exist?(file)

    handle ||= open(file, 'ab')

    keys = ['date', 'day', 'activity', 'time_spent']
    handle << create_markdown_header('Time Report', keys)

    rows = interpret_day_totals(keys)

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
