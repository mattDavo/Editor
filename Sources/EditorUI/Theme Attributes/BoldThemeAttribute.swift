//
//  BoldThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation
import EditorCore

#if os(iOS)
import UIKit

public struct BoldThemeAttribute: ThemeAttribute {
    public var key: String = "bold"
    
    public init() {}
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        
    }
    
}

#elseif os(macOS)
import Cocoa

public struct BoldThemeAttribute: TokenThemeAttribute {
    public var key: String = "bold"
    
    public init() {}
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let font = attrStr.attributes(at: range.location, effectiveRange: nil)[.font] as? NSFont ?? NSFont()
        let traits = font.fontDescriptor.symbolicTraits.union(.bold)
        let desc = font.fontDescriptor.withSymbolicTraits(traits)
        
        if let newFont = NSFont(descriptor: desc, size: font.pointSize) {
            attrStr.addAttribute(.font, value: newFont, range: range)
        }
        else {
            print("Warning: Failed to apply \(key) theme attribute to \(attrStr)")
        }
    }
}

#endif
