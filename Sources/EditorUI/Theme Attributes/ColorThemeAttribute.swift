//
//  ColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

public class ColorThemeAttribute: TokenThemeAttribute {
    
    public let key = "color"
    public let color: Color
    public let altColor: Color?
    
    public init(color: Color, inSelectionScopeColor: Color? = nil) {
        self.color = color
        self.altColor = inSelectionScopeColor
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange, inSelectionScope: Bool) {
        attrStr.addAttribute(.foregroundColor, value: color, range: range)
        if inSelectionScope == true, let altColor = altColor {
            attrStr.addAttribute(.foregroundColor, value: altColor, range: range)
        }
    }
}
