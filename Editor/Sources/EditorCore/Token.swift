//
//  Token.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

struct Token {
    var range: NSRange
    var scopes: [Scope]
    var scopeNames: [String] {
        return scopes.map({$0.name})
    }
}
