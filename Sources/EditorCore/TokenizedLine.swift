//
//  TokenizedLine.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct TokenizedLine {
    
    public var tokens: [Token]
    public var state: LineState
    
    public var length: Int {
        guard let last = tokens.last else {
            return 0
        }
        return last.range.upperBound
    }
    
    mutating func addToken(_ token: Token) {
        cleanLast()
        tokens.append(token)
    }
    
    mutating func addTokens(_ tokens: [Token]) {
        cleanLast()
        self.tokens += tokens
    }
    
    mutating func cleanLast() {
        if tokens.last?.range.length == 0 {
            tokens.removeLast()
        }
    }
    
    mutating func increaseLastTokenLength(by len: Int = 1) {
        tokens[tokens.count - 1].range.length += len
    }
    
    public func applyTheme(_ attributedString: NSMutableAttributedString, at loc: Int) {
        for token in tokens {
            for scope in token.scopes {
                for attr in scope.attributes {
                    attr.apply(to: attributedString, withLineRange: NSRange(location: loc, length: length), tokenRange: NSRange(location: loc + token.range.location, length: token.range.length))
                }
            }
        }
    }
}
