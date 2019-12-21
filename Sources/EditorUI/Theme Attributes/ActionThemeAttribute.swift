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
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        attrStr.addAttribute(.link, value: "", range: tokenRange)
        attrStr.addAttribute(NSAttributedString.Key(rawValue: "linkId"), value: linkId, range: tokenRange)
        attrStr.addAttribute(.underlineColor, value: underlineColor, range: tokenRange)
    }
}
