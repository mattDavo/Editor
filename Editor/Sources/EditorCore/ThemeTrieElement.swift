//
//  ThemeTrieElement.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

class ThemeTrieElement {
    
    var children: [String: ThemeTrieElement]
    var attributes: [String: ThemeAttribute]
    var parentScopeElements: [String: ThemeTrieElement]
    
    init(
        children: [String: ThemeTrieElement],
        attributes: [String: ThemeAttribute],
        parentScopeElements: [String: ThemeTrieElement]
    ) {
        self.children = children
        self.attributes = attributes
        self.parentScopeElements = parentScopeElements
    }
}
