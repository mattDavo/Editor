//
//  Capture.swift
//  
//
//  Created by Matthew Davidson on 7/12/19.
//

import Foundation

public class Capture {
    
    var name: String?
    var patterns: [Pattern]
    
    private var rules: [Rule]?
    
    public init(name: String? = nil, patterns: [Pattern] = []) {
        self.name = name
        self.patterns = patterns
    }
    
    func resolveRules(grammar: Grammar) -> [Rule] {
        if let rules = rules {
            return rules
        }
        var rules = [Rule]()
        for pattern in patterns {
            rules += pattern.resolve(grammar: grammar)
        }
        self.rules = rules
        return rules
    }
}

/*
 
 How are captures applied.
 
 MatchRule:
 Once a match rule is matched.
 We get all the matches.
 We get all the match rules.
 
 Treat each capture as a new "Line" aiming to produce a new tokenized line for each capture then apply those tokenized lines on to the actual tokenized line
 For each matching pair in order:
    If there is a name, apply the name to the
 
name: "",
match: "",
captures: [
   Just straight up apply the name to the match. Doesn't make much sense on 0, but does for other matches.
   0: {
       name
   }
   Apply the patterns to the match. Kind of like recursing.
   1: {
       patterns = []
   }
   Apply the name to the match and then the patterns, kind of like recursing.
   2: {
       name
       patterns = []
   }
]



*/
