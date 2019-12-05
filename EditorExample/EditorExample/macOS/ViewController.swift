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

class ViewController: NSViewController {

    @IBOutlet var textView: EditorTextView!
    var editor: Editor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let lines = """
Hello cat
Catttt, cat dog cat

Hello cat
He said \"Yeah\"
She said \"cat\"
Dogs are better than cats.
Cat should be detected in \"\\(cat)\"

Keywords are dog, Dog, cat and Cat
You're allowed strings: \"It's raining cats and dogs\"
And string interpolation: \"\\(Wow cat dog)\"
Testing out // comments
This shouldn't be commented
/*
* TODO: Woo comment block
*/

_Italic_ *Bold* _Italic and *bold*_ *Bold and _italic_*
"""
        
        textView.string = lines
        
        let grammar = Grammar.test.test03
        grammar.shouldDebug = false
        editor = Editor(textView: textView, grammar: grammar, theme: Theme.tests.basic)
        editor.highlightSyntax()
    }
    
    func reduceAttrString(_ result: NSMutableAttributedString, _ elm: NSAttributedString) -> NSMutableAttributedString {
        result.append(elm)
        return result
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
