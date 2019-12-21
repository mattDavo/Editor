//
//  TailIndentThemeAttribute.swift
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

public struct TailIndentThemeAttribute: ThemeAttribute {
    
    public let key = "tail-indent"
    public let value: CGFloat
    
    public init(value: CGFloat = 0) {
        self.value = value
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        let attr = attrStr.attributes(at: lineRange.location, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
        guard let style = attr.mutableCopy() as? NSMutableParagraphStyle else {
            error("Couldn't create mutable copy of NSParagraphStyle.")
            return
        }
        style.tailIndent = value
        attrStr.addAttribute(.paragraphStyle, value: style, range: lineRange)
    }
}
