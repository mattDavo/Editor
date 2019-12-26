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
    public let hidden: Bool
    public let altHidden: Bool
    
    public init(hidden: Bool = true, inSelectionScopeHidden: Bool = true) {
        self.hidden = hidden
        self.altHidden = inSelectionScopeHidden
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange, inSelectionScope: Bool) {
        if inSelectionScope {
            attrStr.addAttribute(Self.Key, value: altHidden, range: range)
        }
        else {
            attrStr.addAttribute(Self.Key, value: hidden, range: range)
        }
    }
}
