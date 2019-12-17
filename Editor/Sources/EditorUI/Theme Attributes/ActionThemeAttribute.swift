//
//  ActionThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

public struct ActionThemeAttribute: ThemeAttribute {
    
    public let key = "action"
    public let linkId: String
    public let underlineColor: Color
    
    public init(linkId: String, underlineColor: Color = .clear) {
        self.linkId = linkId
        self.underlineColor = underlineColor
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        attrStr.addAttribute(.link, value: "", range: range)
        attrStr.addAttribute(NSAttributedString.Key(rawValue: "linkId"), value: linkId, range: range)
        attrStr.addAttribute(.underlineColor, value: underlineColor, range: range)
    }
}
