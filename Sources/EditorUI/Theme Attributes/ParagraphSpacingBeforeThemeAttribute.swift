//
//  ParagraphSpacingBeforeThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

#if os(iOS)

#elseif os(macOS)
import Cocoa

public struct ParagraphSpacingBeforeThemeAttribute: ThemeAttribute {
    
    public let key = "para-spacing-before"
    public let spacing: CGFloat
    
    public init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        let attr = attrStr.attributes(at: lineRange.location, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
        guard let style = attr.mutableCopy() as? NSMutableParagraphStyle else {
            error("Couldn't create mutable copy of NSParagraphStyle.")
            return
        }
        style.paragraphSpacingBefore = spacing
        attrStr.addAttribute(.paragraphStyle, value: style, range: lineRange)
    }
}

#endif
