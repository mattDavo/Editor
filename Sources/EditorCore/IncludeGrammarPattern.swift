//
//  IncludeGrammarPattern.swift
//
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation

public class IncludeGrammarPattern: Pattern {
    
    public init() {}
    
    public func resolve(grammar: Grammar) -> [Rule] {
        return grammar.rules
    }
}
