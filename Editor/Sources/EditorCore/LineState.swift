//
//  LineState.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

struct LineState {
    var scopes: [Scope]
    
    var currentScope: Scope? {
        return scopes.last
    }
    
    var scopeNames: [String] {
        return scopes.map({$0.name})
    }
}
