//
//  Grammar.swift
//  
//
//  Created by Matthew Davidson on 26/11/19.
//

import Foundation

///
/// The representation of a grammar
///
public class Grammar {
    
    /// The root scope of this grammar.
    public var scopeName: String
    
    /// The file types this grammar should be used for.
    public var fileTypes: [String]
    
    /// The root level patterns for this grammar.
    public var patterns: [Pattern]
    
    /// The folding start marker
    public var foldingStartMarker: String?
    
    /// The folding end marker
    public var foldingStopMarker: String?
    
    /// This grammar's repository of patterns
    public var repository: Repository?
    
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
    
    public func theme(lines: [String], tokenizedLines: [TokenizedLine], withTheme theme: Theme) -> [NSAttributedString] {
        return zip(tokenizedLines, lines).map{$0.0.getThemedLine(line: $0.1)}
    }
    
    public func createFirstLineState(theme: Theme? = nil) -> LineState {
        var scope = Scope(name: scopeName, rules: rules, end: nil)
        if let theme = theme {
            scope.attributes = theme.attributes(forScope: scope.name)
        }
        return LineState(scopes: [scope])
    }
    
    public func baseAttributes(forTheme theme: Theme) -> [NSAttributedString.Key: Any] {
        return theme.attributes(forScope: scopeName).reduce(NSMutableAttributedString(string: "a"), {
        $1.apply(to: $0, withRange: NSRange(location: 0, length: 1))
        return $0
        }).attributes(at: 0, effectiveRange: nil)
    }
    
    public func tokenize(lines: [String], withTheme theme: Theme? = nil) -> [TokenizedLine] {
        debug("\n\n///////// TOKENIZING WITH GRAMMAR: \(scopeName) /////////")
        var state = createFirstLineState(theme: theme)
        var tokenizedLines = [TokenizedLine]()
        for line in lines {
            let tokenizedLine = tokenize(line: line, state: state, withTheme: theme)
            state = tokenizedLine.state
            tokenizedLines.append(tokenizedLine)
        }
        return tokenizedLines
    }
    
    public func tokenize(line: String, state: LineState, withTheme theme: Theme? = nil) -> TokenizedLine {
        debug("Tokenizing line: \(line)")
        var state = state
        var tokenizedLine = TokenizedLine(tokens: [Token(range: NSRange(location: 0, length: 0), scopes: state.scopes)], state: state)
        
        var loc = 0
        while (loc < line.utf16.count) {
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
                        // Set matched flag
                        matched = true
                        // Create a new scope
                        var scope = Scope(name: rule.name, rules: [], attributes: [])
                        // Add theme attributes if we have a theme
                        if let theme = theme {
                            scope.attributes = theme.attributes(forScope: scope.name)
                        }
                        
                        // Create ordered list of tokens
                        // Start with just one token for the entire range of the match.
                        // This will be manipulated if there are capture groups.
                        var tokens = [Token(range: NSRange(location: loc, length: newPos - loc), scopes: state.scopes + [scope])]
                        
                        // Apply capture groups
                        for (i, (captureText, captureRange)) in captures(pattern: rule.match, str: line, at: loc).enumerated() {
                            guard i < rule.captures.count else {
                                // No capture defined for this (or further) capture(/s).
                                break
                            }
                            // Get the capture definition from the rule
                            let capture = rule.captures[i]
                            // Create a scope for the capture.
                            var captureScope = Scope(name: capture.name ?? "", rules: capture.resolveRules(grammar: self))
                            // Apply the theme to the scope
                            if let theme = theme {
                                captureScope.attributes = theme.attributes(forScope: captureScope.name)
                            }
                            // Create the capture state (the current state, with the capture state)
                            let captureState = LineState(scopes: state.scopes + [captureScope])
                            
                            // Use tokenize on the capture as if it was an entire line.
                            var captureLine = tokenize(line: captureText, state: captureState, withTheme: theme)
                            
                            // Adjust the range of tokens to account for the location of the capture.
                            captureLine.tokens = captureLine.tokens.map({
                                var new = $0
                                new.range.location += captureRange.location
                                return new
                            })
                            
                            // Create a new array for the new version of the list of tokens.
                            var newTokens = [Token]()
                            
                            // Merge the original token list with the token list from the tokenized capture line.
                            // Strategy:
                            // While both lists are not empty, take the first from each list and compare.
                            // - If the token from the original list is before the capture list we will either just add it to the new tokens list if it completely before the other token or we will split it and add the front bit to the new list.
                            // - Otherwise, see if the two tokens have the same range. If so, we merge them add them to the list. Otherwise we will split the larger one.
                            // - Note: the capture line tokens will never occur before the original token because captures are applied in order.
                            while var oToken = tokens.first, var cToken = captureLine.tokens.first {
                                // Check if the original token is before the new capture token.
                                if oToken.range.location < cToken.range.location {
                                    var new = oToken
                                    // See if they are disjoint
                                    if oToken.range.upperBound <= cToken.range.location {
                                        tokens.removeFirst()
                                    }
                                    else {
                                        new.range.length = cToken.range.location - oToken.range.location
                                        tokens[0].range = NSRange(location: cToken.range.location, length: oToken.range.upperBound - cToken.range.location)
                                    }
                                    
                                    newTokens.append(new)
                                    continue
                                }
                                
                                // Now we can guarantee that tokens are both at the same location.
                                guard oToken.range.location == cToken.range.location else {
                                    fatalError("Tokens are not contiguous")
                                }
                                
                                // Now three case to merge the tokens:
                                // 1. Both are over the same range
                                // 2. Need to split cToken
                                // 3. Need to split oToken
                                if oToken.range.upperBound == cToken.range.upperBound {
                                    tokens.removeFirst()
                                    captureLine.tokens.removeFirst()
                                }
                                else if oToken.range.upperBound < cToken.range.upperBound {
                                    captureLine.tokens[0].range = NSRange(location: oToken.range.upperBound, length: cToken.range.upperBound - oToken.range.upperBound)
                                    cToken.range.length = oToken.range.length
                                    tokens.removeFirst()
                                }
                                else {
                                    tokens[0].range = NSRange(location: cToken.range.upperBound, length: oToken.range.upperBound - cToken.range.upperBound)
                                    oToken.range.length = cToken.range.length
                                    captureLine.tokens.removeFirst()
                                }
                                // Merge the capture token onto the original token.
                                newTokens.append(oToken.mergedWith(cToken))
                            }
                            // At least one of tokens or capture line tokens will be empty so it safe to just append one of them.
                            newTokens += tokens + captureLine.tokens
                            
                            // Update the tokens.
                            tokens = newTokens
                        }
                        
                        tokenizedLine.addTokens(tokens)
                        
                        // Prepare for next char.
                        loc = newPos
                        tokenizedLine.addToken(Token(range: NSRange(location: loc, length: 0), scopes: state.scopes))
                        break
                    }
                }
                // Apply the begin end rule
                else if let rule = rule as? BeginEndRule {
                    if let newPos = matches(pattern: rule.begin, str: line, at: loc) {
                        matched = true
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
        
        for token in tokenizedLine.tokens {
            let startIndex = line.utf16.index(line.utf16.startIndex, offsetBy: token.range.location)
            let endIndex = line.utf16.index(line.utf16.startIndex, offsetBy: token.range.upperBound)
            debug(" - Token from \(token.range.location) to \(token.range.upperBound) '\(line[startIndex..<endIndex])' with scopes: [\(token.scopeNames.joined(separator: ", "))]")
        }
        debug("")
        
        return tokenizedLine
    }
    
    func matches(pattern: String, str: String, at loc: Int) -> Int? {
        let range = NSRange(location: loc, length: str.utf16.count - loc)
        do {
            let exp = try NSRegularExpression(pattern: pattern, options: .init(arrayLiteral: .anchorsMatchLines, .dotMatchesLineSeparators))
            
            // Must be anchored to the start of the range and enforce word and line boundaries
            let options = NSRegularExpression.MatchingOptions.anchored.union(.withTransparentBounds).union(.withoutAnchoringBounds)
            
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
    
    func captures(pattern: String, str: String, at loc: Int) -> [(String, NSRange)] {
        let range = NSRange(location: loc, length: str.utf16.count - loc)
        do {
            let exp = try NSRegularExpression(pattern: pattern, options: .init(arrayLiteral: .anchorsMatchLines, .dotMatchesLineSeparators))
            
            // Must be anchored to the start of the range and enforce word and line boundaries
            let options = NSRegularExpression.MatchingOptions.anchored.union(.withTransparentBounds).union(.withoutAnchoringBounds)
            
            if let match = exp.firstMatch(in: str, options: options, range: range) {
                return (0..<match.numberOfRanges).map { i -> (String, NSRange) in
                    let captureRange = match.range(at: i)
                    let startIndex = str.index(str.startIndex, offsetBy: captureRange.location)
                    let endIndex = str.index(str.startIndex, offsetBy: captureRange.upperBound)
                    return (String(str[startIndex..<endIndex]), match.range(at: i))
                }
            }
            else {
                return []
            }
        }
        catch {
            print(error)
            print("pattern: \(pattern), str: \(str), loc: \(loc)")
            return []
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
