//
//  UnderlineColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 23/12/19.
//

import Foundation
import EditorCore

public class UnderlineColorThemeAttribute: TokenThemeAttribute {
    
    public let key = "underline-color"
    public let color: Color
    
    public init(color: Color) {
        self.color = color
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange, inSelectionScope: Bool) {
        attrStr.addAttribute(.underlineColor, value: color, range: range)
    }
}
