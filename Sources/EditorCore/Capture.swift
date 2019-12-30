//
//  Capture.swift
//  
//
//  Created by Matthew Davidson on 7/12/19.
//

import Foundation

///
/// The representation of a capture definition.
///
/// Captures can have apply a name (scope) and/or patterns to the captured text.
///
/// The capture group that this `Capture` is applied to is determined by its position in its rules' captures array.
///
public class Capture: Pattern {
    
    /// Optional scope to apply to the capture.
    var name: String?
    
    /// Patterns to apply to the capture.
    var patterns: [Pattern]
    
    /// The lazy resolved rules from the patterns.
    private var rules: [Rule]?
    
    /// Creates a capture.
    ///
    /// - parameter name: Scope to apply to the capture.
    /// - parameter patterns: Patterns to apply to the capture.
    ///
    public init(name: String? = nil, patterns: [Pattern] = []) {
        self.name = name
        self.patterns = patterns
    }
    
    public func resolve(parser: Parser, grammar: Grammar) -> [Rule] {
        if let rules = rules {
            return rules
        }
        var rules = [Rule]()
        for pattern in patterns {
            rules += pattern.resolve(parser: parser, grammar: grammar)
        }
        self.rules = rules
        return rules
    }
}
