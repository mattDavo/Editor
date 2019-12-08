//
//  ViewController.swift
//  EditorExample
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Cocoa
import EditorCore
import EditorDemo
import EditorUI

let theme = Theme(name: "basic", settings: [
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
    ]),
    ThemeSetting(scope: "hidden", parentScopes: [], attributes: [
        FontThemeAttribute(font: .hiddenFont())
    ])
])

public extension Font {
    
    class func hiddenFont() -> Font {
        print(NSFontManager.shared.availableFonts)
        return Font(name: "AdobeBlank", size: 10)!
    }
}


class ViewController: NSViewController {

    @IBOutlet var textView: EditorTextView!
    var editor: Editor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lines = """
Keywords are dog, Dog, cat and Cat

You're allowed strings: "It's raining cats and dogs"
And string interpolation: \"\\(Wow cat dog)\"

Links: [Hello](https://www.google.com)

Testing out // comments

This shouldn't be commented

/*
 * TODO: Woo comment block
 */

_Italic_ *Bold* _Italic and *bold*_ *Bold and _italic_*
"""
        textView.insertionPointColor = .systemBlue
        textView.string = lines
        
        let grammar = Grammar.test.test05
        grammar.shouldDebug = false
        editor = Editor(textView: textView, grammar: grammar, theme: theme)
        
        editor.highlightSyntax()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
