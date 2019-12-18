//
//  TextAlignmentThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 16/12/19.
//

import Foundation
import EditorCore

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public struct TextAlignmentThemeAttribute: ThemeAttribute {
    
    public let key = "first-line-head-indent"
    public let value: NSTextAlignment
    
    public init(value: NSTextAlignment = .natural) {
        self.value = value
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let attr = attrStr.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
        guard let style = attr.mutableCopy() as? NSMutableParagraphStyle else {
            error("Couldn't create mutable copy of NSParagraphStyle.")
            return
        }
        style.alignment = value
        attrStr.addAttribute(.paragraphStyle, value: style, range: attrStr.fullRange)
    }
}
