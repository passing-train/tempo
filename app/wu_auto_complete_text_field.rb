class AutoCompleteTableRowView < NSTableRowView

  def drawSelectionIn(dirtyRect)
    if self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone
      selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
      NSColor.selectedMenuItemColor.setStroke()
      NSColor.selectedMenuItemColor.setFill()
      selectionPath = NSBezierPath.bezierPathWithRoundedRect(selectionRect, xRadius: 0.0, yRadius: 0.0)
      selectionPath.fill()
      selectionPath.stroke()
    end
  end


#    open override var interiorBackgroundStyle:NSBackgroundStyle{
#        get{
#            if self.isSelected {
#                return NSBackgroundStyle.dark
#            }
#            else{
#                return NSBackgroundStyle.light
#            }
#        }
#    }

end



class WuAutoCompleteTextField < NSTextField
  attr_accessor :autoCompleteTableView
  attr_reader :maxResults
  attr_accessor :tableViewDelegate

  def awakeFromNib
    @popOverWidth = 110.0
    @popOverPadding = 0.0
    @maxResults = 10
    @tableViewDelegate = nil

    column1 = NSTableColumn.alloc.initWithIdentifier "text"
    column1.setWidth (@popOverWidth - 2.0 * @popOverPadding)

    tableView = NSTableView.alloc.initWithFrame CGRectZero

    tableView.setSelectionHighlightStyle NSTableViewSelectionHighlightStyleRegular
    tableView.setBackgroundColor NSColor.clearColor
    tableView.setRowSizeStyle NSTableViewRowSizeStyleSmall
    tableView.setIntercellSpacing NSMakeSize(10.0, 0.0)
    tableView.setHeaderView nil
    tableView.setRefusesFirstResponder true
    tableView.setTarget self
    #    tableView.setDoubleAction = #selector(AutoCompleteTextField.insert(_:))
    tableView.addTableColumn(column1)
    tableView.setDelegate self
    tableView.setDataSource self

    @autoCompleteTableView = tableView

    tableSrollView = NSScrollView.alloc.initWithFrame(NSZeroRect)
    tableSrollView.setDrawsBackground false
    tableSrollView.setDocumentView tableView
    tableSrollView.setHasVerticalScroller true

    contentView = NSView.alloc.initWithFrame([[0, 0], [@popOverWidth, 1]])
    contentView.addSubview(tableSrollView)

    contentViewController = NSViewController.alloc.init
    contentViewController.view = contentView

    @autoCompletePopover = NSPopover.alloc.init
    #    @autoCompletePopover.setAppearance  NSAppearance.appearanceNamed(NSAppearanceNameVibrantLight)
    @autoCompletePopover.animates = false
    @autoCompletePopover.contentViewController = contentViewController
    @autoCompletePopover.delegate = self

    @matches = []

  end

  def keyUp(event)
    row = @autoCompleteTableView.selectedRow
    isShow = @autoCompletePopover.isShown

    case event.keyCode
    when 125 #down
      if isShow
        @autoCompleteTableView.selectRowIndexes(NSIndexSet.indexSetWithIndex((row + 1)), byExtendingSelection: false)
        @autoCompleteTableView.scrollRowToVisible(@autoCompleteTableView.selectedRow)
        return #skip default behavior
      end

    when 126 #up
      if isShow
        @autoCompleteTableView.selectRowIndexes(NSIndexSet.indexSetWithIndex((row - 1)), byExtendingSelection: false)
        @autoCompleteTableView.scrollRowToVisible(@autoCompleteTableView.selectedRow)
        return #skip default behavior
      end
    when 36, 48, 49 # return, tab, space
      if isShow
        insert(self)
      end
      return #//skip default behavior
    else
      #break
    end

#    super(theEvent)
    complete(self)
  end

  def complete(sender)
#    lengthOfWord = stringValue.characters.count
    lengthOfWord = stringValue.length
    subStringRange = NSMakeRange(0, lengthOfWord)

    # This happens when we just started a new word or if we have already typed the entire word
    if subStringRange.length == 0 || lengthOfWord == 0
      @autoCompletePopover.close() if @autoCompletePopover
      return
    end

    index = 0
    @matches = completionsForPartialWordRange(subStringRange, indexOfSelectedItem: index)

    p @matches
    if @matches.length > 0

      @autoCompleteTableView.reloadData()
      @autoCompleteTableView.selectRowIndexes(NSIndexSet.indexSetWithIndex(index), byExtendingSelection: false)
      @autoCompleteTableView.scrollRowToVisible(index)

      rect = visibleRect
      @autoCompletePopover.showRelativeToRect(rect, ofView: self, preferredEdge: NSRectEdgeMaxY)
    else
      self.autoCompletePopover.close()
    end

  end

  def insert(sender)
    selectedRow = @autoCompleteTableView.selectedRow
    matchCount = @matches.length

    if selectedRow >= 0 && selectedRow < matchCount
      setStringValue @matches[selectedRow]
      if @tableViewDelegate.respondsToSelector("didSelectItem:selectedItem:")
        #@tableViewDelegate.didSelectItem(stringValue)
      end
    end

    @autoCompletePopover.close()
  end

  def completionsForPartialWordRange(charRange, indexOfSelectedItem: index)

    if @tableViewDelegate.respondsToSelector("textField:completions:forPartialWordRange:indexOfSelectedItem:")

      return self.tableViewDelegate.textField(self, completions:[], forPartialWordRange: charRange, indexOfSelectedItem: index)

    end

    return []
  end


  ### popover delegate
  def popoverWillShow(notification)

#    numberOfRows = min(@autoCompleteTableView.numberOfRows, maxResults)
    numberOfRows = [@autoCompleteTableView.numberOfRows, maxResults].min
    height = (@autoCompleteTableView.rowHeight + @autoCompleteTableView.intercellSpacing.height) * numberOfRows.to_f + 2 * 0.0
    frame = NSMakeRect(0, 0, @popOverWidth, height)

    @autoCompleteTableView.enclosingScrollView.frame = NSInsetRect(frame, @popOverPadding, @popOverPadding)
    @autoCompletePopover.contentSize = NSMakeSize(NSWidth(frame), NSHeight(frame))

  end

  ### NSTableView delegate
  def tableView(tableView, rowViewForRow:row)
    return AutoCompleteTableRowView.alloc.init
  end

  def tableView(tableView, viewForTableColumn:tableColumn, row:myrow)
    cellView = tableView.makeViewWithIdentifier("MyView", owner:self)

    if cellView.nil?
        cellView = NSTableCellView.alloc.initWithFrame(NSZeroRect)
        textField = NSTextField.alloc.initWithFrame(NSZeroRect)
        textField.setBezeled false
        textField.setDrawsBackground false
        textField.setEditable false
        textField.setSelectable false
        cellView.addSubview(textField)
        cellView.textField = textField
        cellView.identifier = "MyView"
    end

    attrs = {
      NSForegroundColorAttributeName => NSColor.blackColor,
      NSFontAttributeName => NSFont.systemFontOfSize(13)
    }

    mutableAttriStr = NSAttributedString.alloc.initWithString(@matches[myrow], attributes: attrs)
    cellView.textField.attributedStringValue = mutableAttriStr

    cellView
  end

  #Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row
  def numberOfRowsInTableView(tableView)
    if @matches.nil?
      0
    else
      @matches.length
    end
  end


end
