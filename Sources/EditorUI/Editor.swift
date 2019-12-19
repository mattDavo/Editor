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
    
    let grammar: Grammar
    
    let theme: Theme

    /// - param textView: The text view which should be observed and highlighted.
    /// - param notificationCenter: The notification center to subscribe in.
    ///   A testing seam. Defaults to `NotificationCenter.default`.
    public init(
        textView: EditorTextView,
        grammar: Grammar,
        theme: Theme,
        notificationCenter: NotificationCenter = .default)
    {
        self.textView = textView
        self.grammar = grammar
        self.theme = theme
        super.init()
        
        textView.delegate = self
        textView.replace(grammar: grammar, theme: theme)
        textView.textContainerInset = NSSize(width: 20, height: 20)
        didHighlightSyntax(textView: textView)
        
        notificationCenter.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textView)
    }

    @objc func textViewDidChange(_ notification: Notification) {
        didHighlightSyntax(textView: textView)
    }
    
    private func didHighlightSyntax(textView: EditorTextView) {
        guard let storage = textView.textStorage as? EditorTextStorage else {
            return
        }
        
        // Set the type attributes to base scope. This is important for the line height of the empty final line in the document and the look of an initially empty document.
        textView.typingAttributes = grammar.baseAttributes(forTheme: theme)
        
        // Layout the view for the invalidated range.
        if let rect = textView.boundingRect(forCharacterRange: storage.lastInvalidatedRange) {
            textView.setNeedsDisplay(rect, avoidAdditionalLayout: false)
        }
        else {
            textView.needsDisplay = true
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
        return true
    }
}

#endif
