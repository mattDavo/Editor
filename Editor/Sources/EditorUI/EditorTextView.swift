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
    
    // MARK: - Attributes
    
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
    
    private var _grammar: Grammar = .default
    private var _theme: Theme = .default
    
    public var grammar: Grammar {
        return _grammar
    }
    
    public var theme: Theme {
        return _theme
    }
    
    /// Holds the attached line number gutter.
    private var lineNumberGutter: LineNumberGutter?

    /// Holds the text color for the gutter.
    public var gutterForegroundColor: NSColor = .textColor {
        didSet {
            if let gutter = self.lineNumberGutter {
                gutter.foregroundColor = gutterForegroundColor
            }
        }
    }

    /// Holds the background color for the gutter.
    public var gutterBackgroundColor: NSColor = .textBackgroundColor {
        didSet {
            if let gutter = self.lineNumberGutter {
                gutter.backgroundColor = gutterBackgroundColor
            }
        }
    }
    
    /// Holds the text color for the current line in the gutter.
    public var gutterCurrentLineForegroundColor: NSColor = .textColor {
        didSet {
            if let gutter = self.lineNumberGutter {
                gutter.currentLineForegroundColor = gutterCurrentLineForegroundColor
            }
        }
    }
    
    /// Holds the background color for the gutter.
    public var gutterWidth: CGFloat = 40 {
        didSet {
            if let gutter = self.lineNumberGutter {
                gutter.ruleThickness = gutterWidth
            }
        }
    }
    
    
    // MARK: - Constructors
    
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
        let storage = EditorTextStorage(grammar: grammar, theme: theme)
        storage.append(attributedString())
        layoutManager?.replaceTextStorage(storage)
        
        isRichText = false
        isAutomaticQuoteSubstitutionEnabled = false
        enabledTextCheckingTypes = 0
        allowsUndo = true
        
        addLineNumberObservers()
    }
    
    /// Add observers to redraw the line number gutter, when necessary.
    internal func addLineNumberObservers() {
      self.postsFrameChangedNotifications = true

        NotificationCenter.default.addObserver(self, selector: #selector(drawGutter), name: NSView.frameDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(drawGutter), name: NSText.didChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(drawGutter), name: NSTextView.didChangeSelectionNotification, object: self)
    }
    
    public func replace(lineNumberGutter: LineNumberGutter) {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
          fatalError("Unwrapping the text views scroll view failed!")
        }
        self.gutterBackgroundColor = lineNumberGutter.backgroundColor
        self.gutterForegroundColor = lineNumberGutter.foregroundColor
        self.gutterCurrentLineForegroundColor = lineNumberGutter.currentLineForegroundColor
        self.lineNumberGutter = lineNumberGutter

        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
    }
    
    @objc internal func drawGutter() {
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
    }
    
    public func replace(grammar: Grammar, theme: Theme) {
        _grammar = grammar
        _theme = theme
        guard let storage = textStorage as? EditorTextStorage else {
            print("Cannot set grammar and them on text storage because it is not of type EditorTextStorage")
            return
        }
        storage.replace(grammar: grammar, theme: theme)
    }
    
    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
        guard let layoutManager = layoutManager else { return nil }
        guard let textContainer = textContainer else { return nil }
        
        // Convert the range for glyphs.
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)

        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
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
