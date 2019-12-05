//
//  ParagraphSpacingAfterThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

#if os(iOS)

#elseif os(macOS)
import Cocoa

public struct ParagraphSpacingAfterThemeAttribute: ThemeAttribute {
    
    public let key = "para-spacing-after"
    public let spacing: CGFloat
    
    public init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let style = (attrStr.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle) as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        style.paragraphSpacing = spacing
        attrStr.addAttribute(.paragraphStyle, value: style, range: range)
    }
}
#endif
