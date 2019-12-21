//
//  FontThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

public struct FontThemeAttribute: ThemeAttribute {
    
    public let key = "font-style"
    public let font: Font
    
    public init(font: Font) {
        self.font = font
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        attrStr.addAttribute(.font, value: font, range: tokenRange)
    }
}
