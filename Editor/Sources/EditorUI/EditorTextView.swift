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
    
    func processSyntaxHighlighting(grammar: Grammar, theme: Theme) {
        if (textStorage as? EditorTextStorage) == nil {
            let storage = EditorTextStorage()
            storage.append(attributedString())
            layoutManager?.replaceTextStorage(storage)
        }
        
        guard let storage = textStorage as? EditorTextStorage else {
            print("This should not happen")
            return
        }
        
        storage.beginEditing()
        storage.processSyntaxHighlighting(grammar: grammar, theme: theme)
        storage.endEditing()
    }
}

#endif
