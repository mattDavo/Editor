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
    
    override init() {
        storage = NSMutableAttributedString(string: "", attributes: nil)
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
    
    func processSyntaxHighlighting(grammar: Grammar, theme: Theme) {
        var lines = grammar.theme(lines: string.split(separator: "\n", omittingEmptySubsequences: false).map({String($0 + "\n")}), withTheme: theme)
        lines.removeLast()
        
        let total = lines.reduce(NSMutableAttributedString(), {
            $0.append($1)
            return $0
        })
        
        total.enumerateAttributes(in: NSRange(location: 0, length: total.length), using: {
            (attributes, range, stop) in
            self.setAttributes(attributes, range: range)
        })
    }
}
#endif
