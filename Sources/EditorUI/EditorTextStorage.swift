//
//  EditorTextStorage.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public class EditorTextStorage: NSTextStorage {
    
    private var storage: NSMutableAttributedString
    
    private var lineRanges: [NSRange]
    
    var lineStartLocs: [Int] {
        return lineRanges.map {$0.location}
    }
    
    private var states = [LineState?]()
    
    private var tokenizedLines = [TokenizedLine?]()
    
    public var lastInvalidatedRange = NSRange(location: 0, length: 0)
    
    private var grammar: Grammar
    
    private var theme: Theme
    
    private var _isProcessingEditing = false
    
    public var isProcessingEditing: Bool {
        _isProcessingEditing
    }
    
    init(grammar: Grammar, theme: Theme) {
        storage = NSMutableAttributedString(string: "", attributes: nil)
        self.lineRanges = [NSRange(location: 0, length: 0)]
        self.grammar = grammar
        self.theme = theme
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not supported")
    }
    
    required init?(pasteboardPropertyList propertyList: AnyObject, ofType type: String) {
        fatalError("\(#function) is not supported")
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("\(#function) is not supported")
    }
    
    // MARK: - Required NSTextStorage methods
    override public var string: String {
        return storage.string
    }

    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }
    
    override public func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        
        // First update the storage
        storage.replaceCharacters(in: range, with:str)
        
        // Then update the line ranges
        updateLineRanges(forCharactersReplacedInRange: range, with: str)
        
        // Check the line ranges in testing
        checkLineRanges()
        
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    private func updateLineRanges(forCharactersReplacedInRange range: NSRange, with str: String) {
        // First remove the line start locations in the affected range
        var line = 0
        if range.length != 0 {
            var foundFirstMatch = false
            while line < lineRanges.count {
                if range.contains(lineRanges[line].location - 1) {
                    foundFirstMatch = true
                    lineRanges.remove(at: line)
                }
                else if !foundFirstMatch {
                    line += 1
                }
                else {
                    break
                }
            }
        }
        
        // Find the line index for where to insert any new line start locations
        line = 0
        while line < lineRanges.count && range.location > lineRanges[line].location - 1 {
            line += 1
        }

        // Find the new line start locations, adding the offset and 1 to get the location of the next line.
        let newLineLocs = str.utf16.indices.filter{ str[$0] == "\n" }.map{
            $0.utf16Offset(in: str) + 1 + range.location }
        
        // Create new line ranges with 0 length.
        let newLineRanges = newLineLocs.map{ NSRange(location: $0, length: 0) }
        lineRanges.insert(contentsOf: newLineRanges, at: line)
        
        // Shift the start locations after inserted ranges.
        for i in line+newLineRanges.count..<lineRanges.count {
            lineRanges[i].location += str.utf16.count - range.length
        }
        
        // Update lengths of new ranges and the one before (as it may have changed)
        for i in max(line-1, 0)..<min(lineRanges.count - 1, line+newLineRanges.count) {
            lineRanges[i].length = lineRanges[i + 1].location - lineRanges[i].location
        }
        
        // If the last line range is a new line range, we set the length based on the text storage.
        if newLineRanges.count + line == lineRanges.count {
            lineRanges[lineRanges.count - 1].length = storage.length - lineRanges[lineRanges.count - 1].location
        }
    }
    
    func checkLineRanges() {
        assert(!lineRanges.isEmpty)
        
        var i = 0
        while i < lineRanges.count-2 {
            assert(lineRanges[i].upperBound == lineRanges[i+1].location)
            i += 1
        }
        
        if let lastNewLine = storage.string.lastIndex(of: "\n")?.utf16Offset(in: storage.string) {
            assert(lineRanges.last!.length == storage.length - (lastNewLine + 1))
        }
        else {
            assert(lineRanges.last?.length == storage.length)
        }
    }
    
    override public func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    ///
    /// Splits the string into lines including the newline character at the end of each of line.
    ///
    /// - Parameter string: The string to split into lines.
    /// - Returns: The string split into an array of newline containing lines.
    /// - Note: if the document ends with a newline character despite the document being rendered as having an extra (empty) line, this is not actually so and is just rendered like this for a better UX. This 'fake' line will not be included in the return value.
    ///
    private func getLines(string: String) -> [String] {
        // Split into lines with each line
        var lines = string.split(separator: "\n", omittingEmptySubsequences: false).map({String($0 + "\n")})
        // Note: even if the string is empty, lines will always have 1 element.
        // Remove the extra newline on the last line.
        lines[lines.count-1].removeLast()
        // Remove the last line if it is empty. Note: whilst text editors will render this last line like it is a line it technically doesn't exist, as really the newline is just part of the previous line.
        if lines.last!.isEmpty {
            lines.removeLast()
        }
        
        // Check the lines array is what we would expect.
        guard string.count == lines.reduce(0, {$0 + $1.count}) else {
            fatalError("Incorrect lines array")
        }
        
        return lines
    }
    
    private func getEditedLines(lineStartLocs: [Int], editedRange: NSRange) -> (Int, Int) {
        var first = 0
        while first < lineStartLocs.count - 1 {
            if editedRange.location < lineStartLocs[first+1] {
                break
            }
            first += 1
        }
        
        // We figure out the last line that was edited.
        var last = first
        while last < lineStartLocs.count - 1 {
            if editedRange.upperBound <= lineStartLocs[last+1] {
                break
            }
            last += 1
        }
        
        return (first, last)
    }
    
    private func getEditedLines(lines: [String], editedRange: NSRange) -> (Int, Int) {
        var firstEditedLine = 0
        var location = 0
        while firstEditedLine < lines.count {
            if editedRange.location < location + lines[firstEditedLine].utf16.count {
                break
            }
            location += lines[firstEditedLine].utf16.count
            firstEditedLine += 1
        }
        
        // We figure out the last line that was edited.
        var lastEditedLine = firstEditedLine
        while lastEditedLine < lines.count {
            if editedRange.upperBound <= location + lines[lastEditedLine].utf16.count {
                break
            }
            location += lines[lastEditedLine].utf16.count
            lastEditedLine += 1
        }
        
        firstEditedLine = min(firstEditedLine, lines.count - 1)
        lastEditedLine = min(lastEditedLine, lines.count - 1)
        
        return (firstEditedLine, lastEditedLine)
    }
    
    ///
    /// Gets the lines that need to be processed at a minimum.
    ///
    /// For typing edits this will normal just return that 1 or 2 lines. Paste edits will be able to return much larger ranges of lines.
    ///
    /// - Parameter lines: The lines to determine which need to be processed.
    /// - Parameter editedRange: The range of characters which have been edited.
    /// - Returns: A tuple of the first line that needs to be processed and the last line that needs to be processed.
    ///
    private func getProcessingLines(lines: [String], editedRange: NSRange) -> (Int, Int) {
        // We figure out the first and last lines that were edited.
        var (firstEditedLine, lastEditedLine) = getEditedLines(lines: lines, editedRange: editedRange)
        
        // We add 1 to the last edited line if a newline was the last character of the edit to extend the edited range to enforce checking the new line as well.
        let text = lines.joined()
        // Take the last edited utf16 character in the range. Since NSRanges are based on utf16 characters.
        let u16Last = text.utf16.index(text.utf16.startIndex, offsetBy: max(editedRange.upperBound - 1, 0))
        // Find it's unicode position, and see if it is a newline
        if let uLast = u16Last.samePosition(in: text.unicodeScalars) {
            if text[uLast] == "\n" {
                lastEditedLine += 1
            }
        }
        
        // Cap the lines incase the position is at the end of the document, which is technically after the last line.
        firstEditedLine = min(firstEditedLine, lines.count - 1)
        lastEditedLine = min(lastEditedLine, lines.count - 1)
        
        return (firstEditedLine, lastEditedLine)
    }
    
    ///
    /// Modifies the length of the states array based on the first edited line to prepare for the processing based of the previous states.
    ///
    /// - Parameter firstEditedLine: The first line that was edited.
    /// - Parameter changeInLines: The number of lines added or deleted.
    ///
    private func adjustStates(firstEditedLine: Int, changeInLines: Int) {
        for _ in 0..<abs(changeInLines) {
            if changeInLines < 0 {
                states.remove(at: firstEditedLine + 1)
            }
            else {
                states.insert(nil, at: firstEditedLine + 1)
            }
        }
    }
    
    ///
    /// Modifies the length of the tokenized lines array based on the first edited line to prepare for the processing based of the previous states.
    ///
    /// - Parameter firstEditedLine: The first line that was edited.
    /// - Parameter changeInLines: The number of lines added or deleted.
    ///
    private func adjustTokenizedLines(firstEditedLine: Int, changeInLines: Int) {
        for _ in 0..<abs(changeInLines) {
            if changeInLines < 0 {
                tokenizedLines.remove(at: firstEditedLine)
            }
            else {
                tokenizedLines.insert(nil, at: firstEditedLine)
            }
        }
    }
    
    private func getCursorLine(lines: [String], editedRange: NSRange) -> Int {
        // We figure out line the cursor will be on
        var location = 0
        var cursorLine = 0
        while cursorLine < lines.count {
            if editedRange.upperBound < location + lines[cursorLine].utf16.count {
                break
            }
            location += lines[cursorLine].utf16.count
            cursorLine += 1
        }
        
        return cursorLine
    }
    
    ///
    /// Processes syntax highlighting on the minimum range possible.
    ///
    /// - Parameter editedRange: The range of the edit, if known. If the edited range is  provided the syntax highlighting will be done by processing the least amount of the document as possible using the pevious state of the document.
    /// - Returns: A tuple containing the edited range and the invalidated range. The edited range is the range of the string that was processed and attributes were applied. The invalidated range is the range of characters that were changed as a result of the edit, e.g. if lines were added or deleted, it will included all of the lines afterwards, so we can re-render the view.
    ///
    func processSyntaxHighlighting(editedRange: NSRange) -> (NSRange, NSRange) {
        // Return if empty
        if string.isEmpty {
            return (fullRange, fullRange)
        }
        
        // Split the string into lines.
        let lines = getLines(string: string)
        
        // Default the processing lines to the entire document.
        var processingLines = (first: 0, last: lines.count-1)
        
        // Calculate the change in number of lines and adjust the states array
        let change = lines.count - states.count + 1
        
        // If we have cached states for the lines we do not need to process the entire string, we can simply on process the lines that have changed or lines afterwards that have been affected by the change.
        if !states.isEmpty && !tokenizedLines.isEmpty {
            processingLines = getProcessingLines(lines: lines, editedRange: editedRange)
            adjustStates(firstEditedLine: processingLines.first, changeInLines: change)
            adjustTokenizedLines(firstEditedLine: processingLines.first, changeInLines: change)
        }
        else {
            // Either both caches are empty or the cache is in an inconsistent state, either way, init both
            tokenizedLines = .init(repeating: nil, count: lines.count)
            states = [grammar.createFirstLineState(theme: theme)]
        }
        
        var processingLine = processingLines.first
        var tokenizedLines = [TokenizedLine]()
        while processingLine <= processingLines.last {
            // Get the state
            guard let state = states[processingLine] else {
                fatalError("State unexpectedly nil for line \(processingLine)")
            }
            
            // Tokenize the line
            let tokenizedLine = grammar.tokenize(line: lines[processingLine], state: state, withTheme: theme)
            tokenizedLines.append(tokenizedLine)
            
            self.tokenizedLines[processingLine] = tokenizedLine
            
            // See if the state (for the next line) was previously cached
            if processingLine + 1 < states.count {
                // Check if we're on the last line and the state is different to the cache
                // If so we need to keep caching
                if processingLine < lines.count - 1 && processingLine == processingLines.last && tokenizedLine.state != states[processingLine + 1] {
                    processingLines.last += 1
                }
                states[processingLine + 1] = tokenizedLine.state
            }
            else {
                // Cache the line
                states.append(tokenizedLine.state)
            }
            
            // Process next line
            processingLine += 1
        }
        
        // Get the line of the cursor (sort of). TODO: Fix. Not always correct. Processing lines are also not always correct, sometimes processing an extra line.
        let cursorLine = getCursorLine(lines: lines, editedRange: editedRange)
        if cursorLine < lines.count {
            selectionLines.removeAll()
            selectionLines.insert(cursorLine)
        }
        
        let startOfProcessing = lines[0..<processingLines.first].reduce(0, {$0 + $1.utf16.count})
        
        var lineLoc = startOfProcessing
        tokenizedLines.enumerated().forEach {
            $1.applyTheme(storage, at: lineLoc, inSelectionScope: $0 + processingLines.first == cursorLine)
            lineLoc += $1.length
        }
        
        let processedRange = NSRange(location: startOfProcessing, length: lineLoc - startOfProcessing)
        
        // Important for fixing fonts where the font does not contain the glyph in the text, e.g. emojis.
        fixAttributes(in: processedRange)
        
        print("Lines processed: \(processingLines.first) to \(processingLines.last)")
        
        let invalidatedRange = (change != 0) ? NSRange(location: startOfProcessing, length: length - startOfProcessing) : processedRange
        
        guard !self.tokenizedLines.contains(where: {$0==nil}) && self.tokenizedLines.count == lines.count else {
            fatalError("Failed to cache tokenized lines correctly")
        }
        
        return (processedRange, invalidatedRange)
    }
    
    public override func processEditing() {
        let editedRange = self.editedRange
        _isProcessingEditing = true
        defer {
            _isProcessingEditing = false
        }
        
        // Replicate super.processEditing() without the fixAttributes as we will do that later
        NotificationCenter.default.post(name: NSTextStorage.willProcessEditingNotification, object: self)
        NotificationCenter.default.post(name: NSTextStorage.didProcessEditingNotification, object: self)
        layoutManagers.forEach { manager in
            manager.processEditing(for: self, edited: editedMask, range: editedRange, changeInLength: changeInLength, invalidatedRange: editedRange)
        }
        
        if !editedMask.contains(.editedCharacters) {
            return
        }
        
        let (range, invalidatedRange) = processSyntaxHighlighting(editedRange: editedRange)
        print("editedRange: \(editedRange)")
        print("Range processed: \(range)")
        print("Range invalidated: \(invalidatedRange)")
        print()
        print("Line start locs.count: \(lineStartLocs.count)")
        
        self.lastInvalidatedRange = invalidatedRange
        
        layoutManagers.forEach { manager in
            manager.processEditing(for: self, edited: .editedAttributes, range: range, changeInLength: 0, invalidatedRange: invalidatedRange)
        }
    }
    
    public func replace(grammar: Grammar, theme: Theme) {
        self.grammar = grammar
        self.theme = theme
        states = []
        edited(.editedAttributes, range: fullRange, changeInLength: 0)
    }
    
    var selectionLines = Set<Int>()
    
    public func updateSelectedRanges(_ selectedRanges: [NSRange]) {
        // Return if empty
        if string.isEmpty {
            return
        }
        
        // Find the lines of selection
        var selectionLines = Set<Int>()
        for range in selectedRanges {
            let (i, j) = getEditedLines(lineStartLocs: self.lineStartLocs, editedRange: range)
            for x in i...j {
                selectionLines.insert(x)
            }
        }
        
        // Find the new and removed lines of selection
        let newLines = selectionLines.subtracting(self.selectionLines)
        let removedLines = self.selectionLines.subtracting(selectionLines)
        
        // Update selectionLines
        self.selectionLines = selectionLines
        
        // Update the selected and unselected lines
        var lineLoc = 0
        var rangesChanged = [NSRange]()
        for (i, tokenizedLine) in tokenizedLines.enumerated() {
            guard let tokenizedLine = tokenizedLine else {
                print("Warning: Unexpectedly found nil tokenized line at index \(i) in updateSelectedRanges")
                continue
            }
            
            if newLines.contains(i) {
                tokenizedLine.applyTheme(storage, at: lineLoc, inSelectionScope: true)
                rangesChanged.append(NSRange(location: lineLoc, length: tokenizedLine.length))
            }
            if removedLines.contains(i) {
                tokenizedLine.applyTheme(storage, at: lineLoc, inSelectionScope: false)
                rangesChanged.append(NSRange(location: lineLoc, length: tokenizedLine.length))
            }
            
            lineLoc += tokenizedLine.length
        }
        
        for rangeChanged in rangesChanged {
            fixAttributes(in: rangeChanged)
            layoutManagers.forEach { manager in
                manager.processEditing(for: self, edited: .editedAttributes, range: rangeChanged, changeInLength: 0, invalidatedRange: rangeChanged)
            }
        }
    }
}
