//
//  File.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore

#if os(macOS)
import Cocoa

public class EditorTextView: NSTextView {
    
    private var _layoutManager: NSLayoutManager?
    
    public override var layoutManager: NSLayoutManager? {
        get {
            if let m = _layoutManager {
                return m
            }
            else {
                _layoutManager = EditorLayoutManager()
                _layoutManager?.addTextContainer(textContainer!)
                textStorage?.addLayoutManager(_layoutManager!)
                return _layoutManager
            }
        }
        set(layoutManager) {
            _layoutManager = layoutManager
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        // Insert NSLayoutManager subclass
        let manager = EditorLayoutManager()
        textContainer?.replaceLayoutManager(manager)
        layoutManager = manager
        
        // Insert NSTextStorage subclass
        let storage = EditorTextStorage()
        storage.append(attributedString())
        layoutManager?.replaceTextStorage(storage)
        
        isRichText = false
        isAutomaticQuoteSubstitutionEnabled = false
        enabledTextCheckingTypes = 0
        allowsUndo = true
    }
    
    func processSyntaxHighlighting(grammar: Grammar, theme: Theme) {
        guard let storage = textStorage as? EditorTextStorage else {
            print("This should not happen")
            return
        }
        
        let prev = selectedRanges
        storage.checkEOF()
        selectedRanges = prev
        
        storage.beginEditing()
        storage.processSyntaxHighlighting(grammar: grammar, theme: theme)
        storage.endEditing()
    }
    
    // Courtesy of: https://christiantietze.de/posts/2017/08/nstextview-fat-caret/
    var caretSize: CGFloat = 4

    open override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
        var rect = rect
        rect.size.width = caretSize
        super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
    }

    open override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
        var rect = rect
        rect.size.width += caretSize - 1
        super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
    }
}

#endif
