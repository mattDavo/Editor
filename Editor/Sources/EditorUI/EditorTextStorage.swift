//
//  EditorTextStorage.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore

#if os(macOS)
import Cocoa

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
    
    func checkEOF() {
        if string.isEmpty || string.last != "\n" {
            append(NSAttributedString(string: "\n"))
        }
    }
    
    @discardableResult
    func processSyntaxHighlighting(grammar: Grammar, theme: Theme, editedRange: NSRange? = nil, changeInLength: Int? = nil) -> (NSRange, NSRange) {
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
        
        var processingLines = (first: 0, last: lines.count-1)
        if let editedRange = editedRange {
            // We figure out the first line that was edited.
            var firstEditedLine = 0
            var location = 0
            while firstEditedLine < lines.count {
                if editedRange.location < location + lines[firstEditedLine].count {
                    break
                }
                location += lines[firstEditedLine].count
                firstEditedLine += 1
            }
            
            // We figure out the last line that was edited.
            var lastEditedLine = firstEditedLine
            while lastEditedLine < lines.count {
                if editedRange.upperBound <= location + lines[lastEditedLine].count {
                    break
                }
                location += lines[lastEditedLine].count
                lastEditedLine += 1
            }
            
            // So we must re-theme at least these lines, potentially more.
            processingLines.first = firstEditedLine
            processingLines.last = lastEditedLine// + 1
        }
        else {
            // If we don't have the edited range, we must process the entire document :(
        }
        
        var haveNumberOfLinesChanged = false
        // If we know the change in length we can determine which lines have been compromised.
        // If the change in length is negative we have had text deleted which means that we need to remove all states from the cache that have been deleted.
        // If the change in length is positive we have had text inserted which means that we need to shuffle down the states to make room for the changes.
        // To do all of this we need to determine how many lines were inserted or deleted.
        if let changeInLength = changeInLength, states.count > 0 {
            let change = abs(lines.count - states.count + 1)
            let first = processingLines.first
            
            print("Number of lines: \(lines.count)")
            print("Number of saved states: \(states.count)")
            print("First line change: \(processingLines.first)")
            print("Lines add/deleted: \(change)")
            
            for _ in 0..<change {
                if changeInLength < 0 {
                    states.remove(at: first+1)
                }
                else {
                    states.insert(nil, at: first+1)
                }
            }
            
            if change > 0 {
                haveNumberOfLinesChanged = true
            }
        }
        
        // Need to check we have a cache
        if states.count <= processingLines.first {
            processingLines.first = max(states.count - 1, 0)
        }
        
        // Cap the last line incase of any deletions
        processingLines.last = min(processingLines.last, lines.count - 1)
        
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
            
            processingLine += 1
        }
        
        let processedLinesRange = processingLines.first..<processingLines.last+1
        let processedLines = Array(lines[processedLinesRange])
        
        let linesProcessed = grammar.theme(lines: processedLines, tokenizedLines: tokenizedLines, withTheme: theme)
        
        let startOfProcessing = lines[0..<processingLines.first].reduce(0, {$0 + $1.count})
        
        let total = linesProcessed.reduce(NSMutableAttributedString(), {
            $0.append($1)
            return $0
        })
        
        total.enumerateAttributes(in: NSRange(location: 0, length: total.length), using: {
            (attributes, range, stop) in
            let realRange = NSRange(location: range.location + startOfProcessing, length: range.length)
            self.setAttributes(attributes, range: realRange)
        })
        
        print("Lines processed: \(processingLines.first)-\(processingLines.first+processedLines.count-1)")
        
        let processedRange = NSRange(location: startOfProcessing, length: total.length)
        let invalidatedRange = haveNumberOfLinesChanged ? NSRange(location: startOfProcessing, length: length - startOfProcessing) : processedRange
        
        return (processedRange, invalidatedRange)
    }
    
    public override func processEditing() {
        super.processEditing()
        
        let (range, invalidatedRange) = processSyntaxHighlighting(grammar: grammar, theme: theme, editedRange: editedRange, changeInLength: changeInLength)
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

#endif

extension NSAttributedString {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}
