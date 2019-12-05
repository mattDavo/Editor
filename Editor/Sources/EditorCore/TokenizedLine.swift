//
//  TokenizedLine.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public struct TokenizedLine {
    var tokens: [Token]
    var state: LineState
    
    mutating func addToken(_ token: Token) {
        cleanLast()
        tokens.append(token)
    }
    
    mutating func cleanLast() {
        if tokens.last?.range.length == 0 {
            tokens.removeLast()
        }
    }
    
    mutating func increaseLastTokenLength(by len: Int = 1) {
        tokens[tokens.count - 1].range.length += len
    }
    
    func getThemedLine(line: String) -> NSAttributedString {
        let str = NSMutableAttributedString(string: line)
        
        for token in tokens {
            for scope in token.scopes {
                for attr in scope.attributes {
                    attr.apply(to: str, withRange: token.range)
                }
            }
        }
        
        return str
    }
}
