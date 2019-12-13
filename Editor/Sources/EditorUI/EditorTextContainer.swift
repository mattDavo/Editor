//
//  EditorTextContainer.swift
//  
//
//  Created by Matthew Davidson on 13/12/19.
//

import Foundation

#if os(macOS)

import Cocoa

class EditorTextContainer: NSTextContainer {
    
    
    override var isSimpleRectangularTextContainer: Bool { return false }
    
    
}

#endif
