//
//  Scope.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

struct Scope {
    var name: String
    var rules: [Rule]
    var end: NSRegularExpression?
    var isContentScope = false
    var attributes: [ThemeAttribute] = []
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
