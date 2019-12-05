//
//  IncludeGrammarPattern.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

public class IncludeGrammarPattern: Pattern {
    
    public init() {}
    
    public func resolve(grammar: Grammar) -> [Rule] {
        return grammar.rules
    }
}
