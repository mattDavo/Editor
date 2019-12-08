//
//  Theme.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

public class Theme {
    
    var name: String
    var settings: [ThemeSetting]
    
    var root: ThemeTrieElement
    
    public init(name: String, settings: [ThemeSetting]) {
        self.name = name
        self.settings = settings
        
        self.root = Theme.createTrie(settings: settings)
    }
    
    static func sortSettings(settings: [ThemeSetting]) -> [ThemeSetting] {
        return settings.sorted { (a, b) -> Bool in
            if a.scopeComponents.count != b.scopeComponents.count {
                return a.scopeComponents.count < b.scopeComponents.count
            }
            return a.parentScopes.count < b.parentScopes.count
        }
    }
    
    static func createTrie(settings: [ThemeSetting]) -> ThemeTrieElement {
        var settings = sortSettings(settings: settings)
        let root = ThemeTrieElement(children: [:], attributes: [:], parentScopeElements: [:])
        
        if settings.count == 0 {
            return root
        }
        
        if settings[0].scope == "" {
            root.attributes = settings.removeFirst().attributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
        }
        
        for setting in settings {
            addSettingToTrie(root: root, setting: setting)
        }
        
        return root
    }
    
    static func addSettingToTrie(root: ThemeTrieElement, setting: ThemeSetting) {
        var curr = root
        var prev: ThemeTrieElement?
        // TODO: Optimise to collapse
        for comp in setting.scopeComponents {
            if let child = curr.children[String(comp)] {
                prev = curr
                curr = child
            }
            else {
                let new = ThemeTrieElement(children: [:], attributes: [:], parentScopeElements: [:])
                curr.children[String(comp)] = new
                prev = curr
                curr = new
            }
        }
        guard prev != nil else {
            print("Error: prev is nil")
            return
        }
        curr.attributes = (prev?.attributes ?? [:])
        for attr in setting.attributes {
            curr.attributes[attr.key] = attr
        }
        
        if setting.parentScopes.count > 0 {
            print("Warning: Theme parent scopes not implemented")
        }
    }
    
    func attributes(forScope scope: String) -> [ThemeAttribute] {
        var curr = root
        for comp in scope.split(separator: ".") {
            if let child = curr.children[String(comp)] {
                curr = child
            }
            else {
                break
            }
        }
        return Array(curr.attributes.values)
    }
}