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
    
    private var states = [LineState?]()
    
    public var lastInvalidatedRange = NSRange(location: 0, length: 0)
    
    private var grammar: Grammar
    
    private var theme: Theme
    
    init(grammar: Grammar, theme: Theme) {
        storage = NSMutableAttributedString(string: "", attributes: nil)
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
        storage.replaceCharacters(in: range, with:str)
        edited(.editedCharacters, range: range,
             changeInLength: (str as NSString).length - range.length)
        endEditing()
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
    /// - Note: if the document ends with a newline character despite the document being rendered as having an extra (empty) line, this is not actually so and is just rendered like this for a better UX. This 'fake' line will be included in the return value.
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
        // We figure out the first line that was edited.
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
        
        // Cap the last line incase the position is at the end of the document, which is technically after the last line.
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
        if states.count > 0 {
            for _ in 0..<abs(changeInLines) {
                if changeInLines < 0 {
                    states.remove(at: firstEditedLine + 1)
                }
                else {
                    states.insert(nil, at: firstEditedLine + 1)
                }
            }
        }
    }
    
    ///
    /// Processes syntax highlighting on the minimum range possible.
    ///
    /// - Parameter editedRange: The range of the edit, if known. If the edited range is  provided the syntax highlighting will be done by processing the least amount of the document as possible using the pevious state of the document.
    /// - Returns: A tuple containing the edited range and the invalidated range. The edited range is the range of the string that was processed and attributes were applied. The invalidated range is the range of characters that were changed as a result of the edit, e.g. if lines were added or deleted, it will included all of the lines afterwards, so we can re-render the view.
    ///
    func processSyntaxHighlighting(editedRange: NSRange? = nil) -> (NSRange, NSRange) {
        // Return if empty
        if string.isEmpty {
            return (storage.fullRange, storage.fullRange)
        }
        
        // Split the string into lines.
        let lines = getLines(string: string)
        
        // Default the processing lines to the entire document.
        var processingLines = (first: 0, last: lines.count-1)
        
        // Calculate the change in number of lines and adjust the states array
        let change = lines.count - states.count + 1
        
        // If we know the edited range and have cached states for the lines we do not need to process the entire string, we can simply on process the lines that have changed or lines afterwards that have been affected by the change.
        if let editedRange = editedRange, !states.isEmpty {
            processingLines = getProcessingLines(lines: lines, editedRange: editedRange)
            adjustStates(firstEditedLine: processingLines.first, changeInLines: change)
        }
        
        // Initialise the cache if it is empty.
        if states.isEmpty {
            states.append(grammar.createFirstLineState(theme: theme))
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
        
        let processedLinesRange = processingLines.first..<processingLines.last+1
        let processedLines = Array(lines[processedLinesRange])
        
        let linesProcessed = grammar.theme(lines: processedLines, tokenizedLines: tokenizedLines, withTheme: theme)
        
        let startOfProcessing = lines[0..<processingLines.first].reduce(0, {$0 + $1.utf16.count})
        
        let total = linesProcessed.reduce(NSMutableAttributedString(), {
            $0.append($1)
            return $0
        })
        
        storage.replaceCharacters(in: NSRange(location: startOfProcessing, length: total.length), with: total)
        // Important for fixing fonts where the font does not contain the glyph in the text, e.g. emojis.
        fixAttributes(in: NSRange(location: startOfProcessing, length: total.length))
        
        print("Lines processed: \(processingLines.first) to \(processingLines.first+processedLines.count-1)")
        
        let processedRange = NSRange(location: startOfProcessing, length: total.length)
        let invalidatedRange = (change != 0) ? NSRange(location: startOfProcessing, length: length - startOfProcessing) : processedRange
        
        return (processedRange, invalidatedRange)
    }
    
    public override func processEditing() {
        let editedRange = self.editedRange
        super.processEditing()
        
        let (range, invalidatedRange) = processSyntaxHighlighting(editedRange: editedRange)
        print("editedRange: \(editedRange)")
        print("Range processed: \(range)")
        print("Range invalidated: \(invalidatedRange)")
        print()
        
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
}
