//
//  ThemeSetting.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct ThemeSetting {
    
    var scope: String
    var parentScopes: [String]
    
    var attributes: [ThemeAttribute]
    
    var scopeComponents: [Substring] {
        return scope.split(separator: ".")
    }
    
    public init(scope: String, parentScopes: [String], attributes: [ThemeAttribute]) {
        self.scope = scope
        self.parentScopes = parentScopes
        self.attributes = attributes
    }
}
