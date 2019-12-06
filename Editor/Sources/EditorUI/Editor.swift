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
        
        notificationCenter.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textView)
    }

    @objc func textViewDidChange(_ notification: Notification) {
        textView.processSyntaxHighlighting(grammar: grammar, theme: theme)
    }
    
    public func highlightSyntax() {
        textView.processSyntaxHighlighting(grammar: grammar, theme: theme)
    }
}

extension Editor: NSTextViewDelegate {
    
    public func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        return true
    }
    
    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        // TODO: Implement a nice action when deleting last line, so that the last line isn't deleted but the caret moves.
        return true
    }
}

#endif
