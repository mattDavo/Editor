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
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: 18)),
        LineHeightThemeAttribute(min: 30, max: 30),
        FirstLineHeadIndentThemeAttribute(value: 30),
        TailIndentThemeAttribute(value: -30),
        HeadIndentThemeAttribute(value: 30)
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
    ]),
    ThemeSetting(scope: "markup.heading.1", parentScopes: [], attributes: [
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: 25)),
        FirstLineHeadIndentThemeAttribute(value: 2)
    ]),
    ThemeSetting(scope: "markup.center", parentScopes: [], attributes: [
        BackgroundColorThemeAttribute(color: NSColor.gray, rounded: true),
        TextAlignmentThemeAttribute(value: .center)
    ])
])

public extension Font {
    
    class func hiddenFont() -> Font {
        return Font(name: "AdobeBlank", size: 10)!
    }
}


class ViewController: NSViewController {

    @IBOutlet var textView: EditorTextView!
    var editor: Editor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lines = """
# My Heading

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

Emojis are allowed 😊
"""
        textView.insertionPointColor = .systemBlue
        textView.string = lines
        textView.replace(lineNumberGutter: LineNumberGutter(withTextView: textView))
        
        let grammar = Grammar.test.test05
        grammar.shouldDebug = true
        editor = Editor(textView: textView, grammar: grammar, theme: theme)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
