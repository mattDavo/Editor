//
//  LineHeightThemeAttribute.swift
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

public struct LineHeightThemeAttribute: ThemeAttribute {
    
    public let key = "line-height"
    public let min: CGFloat
    public let max: CGFloat
    
    public init(min: CGFloat = 0, max: CGFloat = 0) {
        self.min = min
        self.max = max
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange) {
        let attr = attrStr.attributes(at: lineRange.location, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
        guard let style = attr.mutableCopy() as? NSMutableParagraphStyle else {
            error("Couldn't create mutable copy of NSParagraphStyle.")
            return
        }
        style.minimumLineHeight = min
        style.maximumLineHeight = max
        attrStr.addAttribute(.paragraphStyle, value: style, range: lineRange)
    }
}
