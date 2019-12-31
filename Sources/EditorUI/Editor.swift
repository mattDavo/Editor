//
//  Editor.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

#if os(macOS)
import Cocoa

public class Editor: NSObject {
    
    let textView: EditorTextView
    
    let parser: Parser
    
    let grammar: Grammar
    
    let theme: Theme

    /// - param textView: The text view which should be observed and highlighted.
    /// - param notificationCenter: The notification center to subscribe in.
    ///   A testing seam. Defaults to `NotificationCenter.default`.
    public init(
        textView: EditorTextView,
        parser: Parser,
        baseGrammar: Grammar,
        theme: Theme,
        notificationCenter: NotificationCenter = .default)
    {
        self.textView = textView
        self.parser = parser
        self.grammar = baseGrammar
        self.theme = theme
        super.init()
        
        textView.delegate = self
        textView.layoutManager?.delegate = self
        textView.replace(parser: parser, baseGrammar: baseGrammar, theme: theme)
        textView.textContainerInset = NSSize(width: 20, height: 20)
        // Set the type attributes to base scope. This is important for the line height of the empty final line in the document and the look of an initially empty document.
        textView.typingAttributes = baseGrammar.baseAttributes(forTheme: theme)
        didHighlightSyntax(textView: textView)
        
        notificationCenter.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textView)
    }

    @objc func textViewDidChange(_ notification: Notification) {
        didHighlightSyntax(textView: textView)
    }
    
    private func didHighlightSyntax(textView: EditorTextView) {
        guard let storage = textView.textStorage as? EditorTextStorage,
            let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer else {
            return
        }
        
        // Layout the view for the invalidated visible range.
        // Get the visible range
        let visibleRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        // Get the intersection of the invalidated range and visible range.
        // If there is no intersection, no display needed.
        if let visibleInvalid = visibleRange.intersection(storage.lastInvalidatedRange) {
            // Try to get the bounding rect of the invalid range and only re-render it, otherwise re-render the entire text view.
            if let rect = textView.boundingRect(forCharacterRange: visibleInvalid) {
                textView.setNeedsDisplay(rect, avoidAdditionalLayout: false)
            }
            else {
                textView.needsDisplay = true
            }
        }
        
        // Check EOF
        if !storage.string.isEmpty && storage.string.last != "\n" {
            let prev = textView.selectedRanges
            storage.append(NSAttributedString(string: "\n"))
            textView.selectedRanges = prev
        }
    }
}

extension Editor: NSTextViewDelegate {
    
    public func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        var linkRange = NSRange(location: 0, length: 0)
        
        guard let id = link as? String,
            let handler = textView.attributedString().attribute(ActionThemeAttribute.HandlerKey, at: charIndex, effectiveRange: &linkRange) as? ActionThemeAttribute.Handler,
            linkRange.length > 0 else {
            return false
        }
        
        print(linkRange)
        let str = (textView.string as NSString).substring(with: linkRange)
        
        handler(str, linkRange)
        
        return true
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? EditorTextView,
            let storage = textView.textStorage as? EditorTextStorage else {
            return
        }
        
        if !storage.isProcessingEditing {
            var rangesChanged = storage.updateSelectedRanges(textView.selectedRanges.map{$0.rangeValue})
            
            // If there are any lines that changed
            if !rangesChanged.isEmpty {
                // Union all of the ranges
                let first = rangesChanged.removeFirst()
                let totalChange = rangesChanged.reduce(first, {
                    return $0.union($1)
                })
                
                // And re-display. This is important for rounded highlighting for full lines to ensure that rounding is not applied in the middle.
                if let rect = textView.boundingRect(forCharacterRange: totalChange) {
                    textView.setNeedsDisplay(rect, avoidAdditionalLayout: false)
                }
                else {
                    textView.needsDisplay = true
                }
            }
        }
    }
}

extension Editor: NSLayoutManagerDelegate {
    
    // Inspiration from: https://stackoverflow.com/a/57697139
    public func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: NSFont, forGlyphRange glyphRange: NSRange) -> Int {
        
        guard let storage = layoutManager.textStorage else {
            return 0
        }
        
        // Allocate for glyph modification
        let modifiedGlyphProperties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty> = .allocate(capacity: glyphRange.length)
        
        // Calculate the character range
        let firstCharIndex = charIndexes[0]
        let lastCharIndex = charIndexes[glyphRange.length - 1]
        let charactersRange = NSRange(location: firstCharIndex, length: lastCharIndex - firstCharIndex + 1)
        
        // Find the ranges that need to be hidden
        var hiddenRanges = [NSRange]()
        storage.enumerateAttribute(HiddenThemeAttribute.Key, in: charactersRange, using: { value, range, stop in
            guard value as? Bool == true else {
                return
            }
            
            hiddenRanges.append(range)
        })
        
        // Set the glyph properties
        for i in 0 ..< glyphRange.length {
            let characterIndex = charIndexes[i]
            modifiedGlyphProperties[i] = props[i]

            let matchingHiddenRanges = hiddenRanges.filter { NSLocationInRange(characterIndex, $0) }
            if !matchingHiddenRanges.isEmpty {
                // Note: .null is the value that makes sense here, however it causes strange indentation issues when the first glyph on the line is hidden.
                modifiedGlyphProperties[i] = .controlCharacter
            }
        }
        
        // Set the new glyphs
        layoutManager.setGlyphs(glyphs, properties: modifiedGlyphProperties, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
        
        return glyphRange.length
    }
}

#endif
