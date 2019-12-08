//
//  IncludeRulePattern.swift
//  
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

public class IncludeRulePattern: Pattern {
    
    var include: String
    
    public init(include: String) {
        self.include = include
    }
    
    public func resolve(grammar: Grammar) -> [Rule] {
        guard let repo = grammar.repository else {
            print("Warning: Failed to resolve include rule with value: \(include) because grammar repository is nil.")
            return []
        }
        guard let rule = repo.patterns[include] else {
            print("Warning: Failed to resolve include rule with value: \(include) because the grammar repository does not contain a pattern with name: \(include)")
            return []
        }
        return rule.resolve(grammar: grammar)
    }
}
