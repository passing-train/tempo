class Entry < CDQManagedObject

  def customer_name
    customer = Customer.where(:customer_id).eq(customer_id).first if customer_id
    if customer
      customer.name
    else
      ''
    end
  end

  def project_description
    project = Project.where(:project_id).eq(project_id).first if project_id
    if project
      project.project_description
    else
      ''
    end
  end

  def first_activity_date
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"

    entry = Entry.where(:title).eq(title).sort_by('created_at', order: :ascending).first
    @dateFormat.stringFromDate(entry.created_at)
  end

  def last_activity_date
    @dateFormat = NSDateFormatter.new
    @dateFormat.setDateFormat "YYYY-MM-dd"

    entry = Entry.where(:title).eq(title).sort_by('created_at', order: :descending).first
    @dateFormat.stringFromDate(entry.created_at)
  end

  def total_time_in_seconds today_only=false

    last_only = true
    last_entry = nil
    block_total = 0
    cum_start_time = 0
    keys = ['created_at','time_spent', 'block_total_secs']
    total_secs = 0
    rows = []

    i = 0

    today = Date.today.to_s[0,10]
    entries = Entry.where(:title).eq(title).sort_by('created_at')

    entries.each do |entry|

      if today_only
        next unless today == TimeUtility::dateFormat.stringFromDate(entry.created_at)
      end

      if block_total == 0 ||  cum_start_time == 0
        cum_start_time = TimeUtility::timeFormat.stringFromDate(entry.created_at)
      end

      if Entry.all.sort_by('created_at')[i]
        day_next_entry = TimeUtility::dateFormat.stringFromDate(Entry.all.sort_by('created_at')[i].created_at)
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

      block_total += entry.extra_time

      time_delta_display = TimeUtility::format_time_from_seconds block_total

      # weergeven als nieuwe dag of laatste blok
      if entry.last_in_block? ||
          TimeUtility::dateFormat.stringFromDate(entry.created_at) != day_next_entry ||
          work_break
        block_total_display = TimeUtility::format_time_from_seconds block_total
        block_total_secs = block_total
        block_total = 0
      else
        block_total_display = ''
      end

      row = GeneralUtility::interpret_add_key_val(row, keys, 'date', TimeUtility::dateFormat.stringFromDate(entry.created_at))
      row = GeneralUtility::interpret_add_key_val(row, keys, 'created_at', entry.created_at)
      row = GeneralUtility::interpret_add_key_val(row, keys, 'time_spent', block_total_display)
      row = GeneralUtility::interpret_add_key_val(row, keys, 'block_total_secs', block_total_secs)

      if !last_only ||
          entry.last_in_block? ||
          TimeUtility::dateFormat.stringFromDate(entry.created_at) != day_next_entry ||
          work_break ||
          time_delta_display == '00:00'

        rows << row
      end

      last_entry = entry

    end

    rows.each do | r |
      total_secs = total_secs + r['block_total_secs']
    end

    total_secs
  end

  def time_today
    TimeUtility::format_time_from_seconds total_time_in_seconds true
  end

  def total_time
    TimeUtility::format_time_from_seconds total_time_in_seconds false
  end

end
