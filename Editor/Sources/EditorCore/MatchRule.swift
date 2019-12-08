//
//  MatchRule.swift
//
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

public class MatchRule: Rule, Pattern {
    var name: String
    var match: String
    var captures: [Capture]
    
    public init(
        name: String,
        match: String,
        captures: [Capture] = []
    ) {
        self.name = name
        self.match = match
        self.captures = captures
    }
    
    public func resolve(grammar: Grammar) -> [Rule] {
        return [self]
    }
}
