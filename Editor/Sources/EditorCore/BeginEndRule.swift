//
//  BeginEndRule.swift
//
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

///
/// The representation of the Begin/End rule.
///
public class BeginEndRule: Rule, Pattern {
    
    public let id: UUID
    
    /// The name of the rule, i.e. the scope.
    var name: String
    
    /// The begin regex for the rule.
    ///
    /// Ensure special characters are escaped correctly.
    var begin: String
    
    /// The end regex for the rule.
    ///
    /// Ensure special characters are escaped correctly.
    var end: String
    
    /// The patterns to apply within the begin and end patterns.
    var patterns: [Pattern]
    
    /// The name/scope assigned to text matched between the begin/end patterns.
    var contentName: String?
    
    /// TODO:
    var beginCaptures: [String]
    /// TODO:
    var endCaptures: [String]
    
    private var rules: [Rule]?
    
    public init(
        name: String,
        begin: String,
        end: String,
        patterns: [Pattern],
        contentName: String? = nil,
        beginCaptures: [String] = [],
        endCaptures: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.begin = begin
        self.end = end
        self.patterns = patterns
        self.contentName = contentName
        self.beginCaptures = beginCaptures
        self.endCaptures = endCaptures
    }
    
    public func resolve(grammar: Grammar) -> [Rule] {
        return [self]
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
