//
//  BackgroundColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 6/12/19.
//

import Foundation
import EditorCore

public struct BackgroundColorThemeAttribute: ThemeAttribute {
    
    public var key = "background-color"
    public var color: Color
    public var rounded: Bool
    
    public init(color: Color, rounded: Bool = false) {
        self.color = color
        self.rounded = rounded
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        attrStr.addAttribute(.backgroundColor, value: color, range: tokenRange)
        if rounded {
            attrStr.addAttribute(NSAttributedString.Key("isBackgroundColorRounded"), value: true, range: tokenRange)
        }
    }
}
