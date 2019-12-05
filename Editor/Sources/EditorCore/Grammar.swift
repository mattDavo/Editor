//
//  Grammar.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

///
/// The representation of a grammar
///
public class Grammar {
    
    /// The root scope of this grammar.
    var scopeName: String
    
    /// The file types this grammar should be used for.
    var fileTypes: [String]
    
    /// The root level patterns for this grammar.
    var patterns: [Pattern]
    
    /// The folding start marker
    var foldingStartMarker: String?
    
    /// The folding end marker
    var foldingStopMarker: String?
    
    /// This grammar's repository of patterns
    var repository: Repository?
    
    private var _rules: [Rule]?
    
    var rules: [Rule] {
        if let rules = _rules {
            return rules
        }
        _rules = resolveRules()
        return _rules!
    }
    
    public init(
        scopeName: String,
        fileTypes: [String] = [],
        patterns: [Pattern] = [],
        foldingStartMarker: String? = nil,
        foldingStopMarker: String? = nil,
        repository: Repository? = nil
    ) {
        self.scopeName = scopeName
        self.fileTypes = fileTypes
        self.patterns = patterns
        self.foldingStartMarker = foldingStartMarker
        self.foldingStopMarker = foldingStopMarker
        self.repository = repository
    }
    
    public func theme(lines: [String], withTheme theme: Theme) -> [NSAttributedString] {
        return zip(tokenize(lines: lines, withTheme: theme), lines).map{$0.0.getThemedLine(line: $0.1)}
    }
    
    public func tokenize(lines: [String], withTheme theme: Theme? = nil) -> [TokenizedLine] {
        debug("\n\n///////// TOKENIZING WITH GRAMMAR: \(scopeName) /////////")
        var scope = Scope(name: scopeName, rules: rules, end: nil)
        if let theme = theme {
            scope.attributes = theme.attributes(forScope: scope.name)
        }
        var state = LineState(scopes: [scope])
        var tokenizedLines = [TokenizedLine]()
        for line in lines {
            debug("Tokenizing line: \(line)")
            let tokenizedLine = tokenize(line: line, state: state, withTheme: theme)
            state = tokenizedLine.state
            tokenizedLines.append(tokenizedLine)
            for token in tokenizedLine.tokens {
                let startIndex = line.index(line.startIndex, offsetBy: token.range.location)
                let endIndex = line.index(line.startIndex, offsetBy: token.range.upperBound)
                debug(" - Token from \(token.range.location) to \(token.range.upperBound) '\(line[startIndex..<endIndex])' with scopes: [\(token.scopeNames.joined(separator: ", "))]")
            }
            debug("")
        }
        return tokenizedLines
    }
    
    func tokenize(line: String, state: LineState, withTheme theme: Theme? = nil) -> TokenizedLine {
        var state = state
        var tokenizedLine = TokenizedLine(tokens: [Token(range: NSRange(location: 0, length: 0), scopes: state.scopes)], state: state)
        
        var loc = 0
        while (loc < line.count) {
            // Before we apply the rules in the current scope, see if we are in a BeginEndRule and reached the end of its scope.
            if let endPattern = state.currentScope?.end {
                if let newPos = matches(pattern: endPattern, str: line, at: loc) {
                    state.scopes.removeLast()
                    tokenizedLine.increaseLastTokenLength(by: newPos - loc)
                    loc = newPos
                    tokenizedLine.addToken(Token(range: NSRange(location: loc, length:0), scopes: state.scopes))
                    continue
                }
            }
            
            // Get the current scope, to get the rules.
            // There may not always be rules, but there should always be a scope
            guard let scope = state.currentScope else {
                // Shouldn't happen
                return tokenizedLine
            }
            
            // Apply the rules in order, looking for a match
            var matched = false
            for rule in scope.rules {
                // Apply the match rule
                if let rule = rule as? MatchRule {
                    if let newPos = matches(pattern: rule.match, str: line, at: loc) {
                        matched = true
                        // Old
                        var scope = Scope(name: rule.name, rules: [], attributes: [])
                        if let theme = theme {
                            scope.attributes = theme.attributes(forScope: scope.name)
                        }
                        tokenizedLine.addToken(Token(range: NSRange(location: loc, length: newPos - loc), scopes: state.scopes + [scope]))
                        
                        loc = newPos
                        tokenizedLine.addToken(Token(range: NSRange(location: loc, length: 0), scopes: state.scopes))
                        break
                    }
                }
                // Apply the begin end rule
                else if let rule = rule as? BeginEndRule {
                    if let newPos = matches(pattern: rule.begin, str: line, at: loc) {
                        matched = true
                        // Old
                        var scope = Scope(name: rule.name, rules: rule.resolveRules(grammar: self), end: rule.end)
                        if let theme = theme {
                            scope.attributes = theme.attributes(forScope: scope.name)
                        }
                        state.scopes.append(scope)
                        tokenizedLine.addToken(Token(range: NSRange(location: loc, length: newPos - loc), scopes: state.scopes))
                        loc = newPos
                        break
                    }
                }
            }
            // No matches at the current position.
            // Increase the length of the current token and move to the next character.
            if !matched {
                tokenizedLine.increaseLastTokenLength()
                loc += 1
            }
        }
        tokenizedLine.cleanLast()
        tokenizedLine.state = state
        
        return tokenizedLine
    }
    
    func matches(pattern: String, str: String, at loc: Int) -> Int? {
        let range = NSRange(location: loc, length: str.count - loc)
        do {
            let exp = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
            
            // Must be anchored to the start of the range
            var options = NSRegularExpression.MatchingOptions.anchored
            
            // Enforce ^ and $ for strings not at the start
            // Essentially ensuring if the pattern is anchored to the start and loc != 0, it will not match
            if loc != 0 {
                options.update(with: .withoutAnchoringBounds)
            }
            if let match = exp.firstMatch(in: str, options: options, range: range) {
                return match.range.upperBound
            }
            else {
                return nil
            }
        }
        catch {
            print(error)
            print("pattern: \(pattern), str: \(str), loc: \(loc)")
            return nil
        }
    }
    
    private func resolveRules() -> [Rule] {
        var rules = [Rule]()
        
        for pattern in patterns {
            rules += pattern.resolve(grammar: self)
        }
        
        return rules
    }
    
    public var shouldDebug = false
    
    func debug(_ str: String) {
        if shouldDebug {
            print(str)
        }
    }
}
