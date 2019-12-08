//
//  Theme+Tests.swift
//  
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation
import EditorCore

extension Theme {
    
    public struct tests {
        
        public static let basic = Theme(name: "basic", settings: [
            ThemeSetting(scope: "comment", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .systemGreen)
            ]),
            ThemeSetting(scope: "constant", parentScopes: [], attributes: []),
            ThemeSetting(scope: "entity", parentScopes: [], attributes: []),
            ThemeSetting(scope: "invalid", parentScopes: [], attributes: []),
            ThemeSetting(scope: "keyword", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .systemBlue)
            ]),
            ThemeSetting(scope: "markup", parentScopes: [], attributes: []),
            ThemeSetting(scope: "storage", parentScopes: [], attributes: []),
            ThemeSetting(scope: "string", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .systemRed)
            ]),
            ThemeSetting(scope: "support", parentScopes: [], attributes: []),
            ThemeSetting(scope: "variable", parentScopes: [], attributes: []),
            ThemeSetting(scope: "source", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .textColor),
                FontThemeAttribute(font: .monospacedSystemFont(ofSize: 20)),
                ParagraphSpacingBeforeThemeAttribute(spacing: 5),
                ParagraphSpacingAfterThemeAttribute(spacing: 5)
            ]),
            ThemeSetting(scope: "comment.keyword", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .systemTeal)
            ]),
            ThemeSetting(scope: "markup.bold", parentScopes: [], attributes: [
                BoldThemeAttribute()
            ]),
            ThemeSetting(scope: "markup.italic", parentScopes: [], attributes: [
                ItalicThemeAttribute()
            ]),
            ThemeSetting(scope: "markup.mono", parentScopes: [], attributes: [
                BackgroundColorThemeAttribute(color: .gray, rounded: true),
            ]),
            ThemeSetting(scope: "action", parentScopes: [], attributes: [
                ActionThemeAttribute(linkId: "test")
            ])
        ])
    }
}


#if os(iOS)
import UIKit

public extension UIFont {

    class func italicSystemFont(ofSize size: CGFloat) -> UIFont {
        var symTraits = fontDescriptor().symbolicTraits
        symTraits.insert([.TraitBold])
        let fontDescriptorVar = fontDescriptor().fontDescriptorWithSymbolicTraits(symTraits)
        return UIFont(descriptor: fontDescriptorVar, size: size)
    }
}

#elseif os(macOS)
import Cocoa
public extension NSFont {
    class func italicSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont(descriptor: NSFontDescriptor().withSymbolicTraits(.italic), size: size)!
    }
}

public extension NSFont {
    class func monospacedSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont(name: "SpaceMono-Regular", size: size)!
    }
}

#endif
