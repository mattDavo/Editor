//
//  ItalicThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 5/12/19.
//

import Foundation

#if os(iOS)
import UIKit

public struct ItalicThemeAttribute: ThemeAttribute {
    public var key: String = "italic"
    
    public init() {}
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        
    }
}

#elseif os(macOS)
import Cocoa

public struct ItalicThemeAttribute: ThemeAttribute {
    public var key: String = "italic"
    
    public init() {}
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let font = attrStr.attributes(at: range.location, effectiveRange: nil)[.font] as? NSFont ?? NSFont()
        let traits = font.fontDescriptor.symbolicTraits.union(.italic)
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
