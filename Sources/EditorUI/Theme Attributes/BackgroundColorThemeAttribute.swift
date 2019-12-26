//
//  BackgroundColorThemeAttribute.swift
//  
//
//  Created by Matthew Davidson on 6/12/19.
//

import Foundation
import EditorCore

public class BackgroundColorThemeAttribute: TokenThemeAttribute {
    
    public struct RoundedBackgroundStyle: Hashable, Equatable, RawRepresentable {
        
        public let rawValue: CGFloat
        
        public init(rawValue: CGFloat) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: CGFloat) {
            self.rawValue = rawValue
        }
        
        public static let none = RoundedBackgroundStyle(0)
        public static let full = RoundedBackgroundStyle(1)
        public static let half = RoundedBackgroundStyle(0.5)
        public static let quarter = RoundedBackgroundStyle(0.25)
    }
    
    public struct RoundedBackground {
        
        public static let Key = NSAttributedString.Key(rawValue: "EditorUI.RoundedBackgroundColor")
        
        let color: Color
        let style: RoundedBackgroundStyle
    }
    
    public var key = "background-color"
    public var color: Color
    public var roundingStyle: RoundedBackgroundStyle
    
    public init(color: Color, roundingStyle: RoundedBackgroundStyle = .none) {
        self.color = color
        self.roundingStyle = roundingStyle
    }
    
    public func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange, inSelectionScope: Bool) {
        if roundingStyle == .none {
            attrStr.addAttribute(.backgroundColor, value: color, range: range)
        }
        else {
            attrStr.addAttribute(RoundedBackground.Key, value: RoundedBackground(color: color, style: roundingStyle), range: range)
        }
    }
}
