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
    var end: String?
    var attributes: [ThemeAttribute] = []
}
