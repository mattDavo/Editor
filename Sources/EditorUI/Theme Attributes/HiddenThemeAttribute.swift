//
//  HiddenThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 26/12/19.
//

import Foundation
import EditorCore

public class HiddenThemeAttribute: TokenThemeAttribute {
    
    public static let Key = NSAttributedString.Key(rawValue: "EditorUI.Hidden")
    
    public let key = "hidden"
    
    public init() {}
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange, inSelectionScope: Bool) {
        attrStr.addAttribute(Self.Key, value: true, range: range)
    }
}
