//
//  Scope.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

class Scope {
    var name: String
    var rules: [Rule]
    var end: NSRegularExpression?
    var attributes: [ThemeAttribute]
    var isContentScope = false
    
    init(
        name: String,
        rules: [Rule],
        end: NSRegularExpression? = nil,
        attributes: [ThemeAttribute],
        isContentScope: Bool = false
    ) {
        self.name = name
        self.rules = rules
        self.end = end
        self.attributes = attributes
        self.isContentScope = isContentScope
    }
}

extension Scope: Equatable {
    
    static func == (lhs: Scope, rhs: Scope) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.end != rhs.end { return false }
        if lhs.rules.count != rhs.rules.count { return false }
        for (l, r) in zip(lhs.rules, rhs.rules) {
            if l != r {
                return false
            }
        }
        return true
    }
}
