//
//  Theme+Tests.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
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
                FontThemeAttribute(font: .systemFont(ofSize: 12)),
                ParagraphSpacingBeforeThemeAttribute(spacing: 5),
                ParagraphSpacingAfterThemeAttribute(spacing: 5)
            ]),
            ThemeSetting(scope: "comment.keyword", parentScopes: [], attributes: [
                ColorThemeAttribute(color: .systemTeal)
            ]),
            ThemeSetting(scope: "markup.bold", parentScopes: [], attributes: [
                FontThemeAttribute(font: .boldSystemFont(ofSize: 12))
            ]),
            ThemeSetting(scope: "markup.italic", parentScopes: [], attributes: [
            ]),
            ThemeSetting(scope: "action", parentScopes: [], attributes: [
                ActionThemeAttribute(linkId: "test")
            ])
        ])
    }
}
