//
//  Rule.swift
//  
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

public protocol Rule: Pattern {
    
    var id: UUID { get }
}

// See here for why we can't just inherit from equatable: https://khawerkhaliq.com/blog/swift-protocols-equatable-part-one/
func ==(lhs: Rule, rhs: Rule) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    return lhs.id == rhs.id
}

func !=(lhs: Rule, rhs: Rule) -> Bool {
    return !(lhs == rhs)
}
