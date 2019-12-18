//
//  ParagraphSpacingAfterThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation
import EditorCore

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public struct ParagraphSpacingAfterThemeAttribute: ThemeAttribute {
    
    public let key = "para-spacing-after"
    public let spacing: CGFloat
    
    public init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange) {
        let attr = attrStr.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
        guard let style = attr.mutableCopy() as? NSMutableParagraphStyle else {
            error("Couldn't create mutable copy of NSParagraphStyle.")
            return
        }
        style.paragraphSpacing = spacing
        attrStr.addAttribute(.paragraphStyle, value: style, range: attrStr.fullRange)
    }
}
