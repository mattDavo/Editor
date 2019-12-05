//
//  Language.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

struct Language {
    var grammar: Grammar
    
    func tokenize(lines: [String]) {
        grammar.tokenize(lines: lines)
    }
}
