//
//  TokenizedLine.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public class TokenizedLine {
    
    var tokens: [Token]
    public var state: LineState
    
    init(tokens: [Token] = [], state: LineState) {
        self.tokens = tokens
        self.state = state
    }
    
    public var length: Int {
        guard let last = tokens.last else {
            return 0
        }
        return last.range.upperBound
    }
    
    func addToken(_ token: Token) {
        cleanLast()
        tokens.append(token)
    }
    
    func addTokens(_ tokens: [Token]) {
        cleanLast()
        self.tokens += tokens
    }
    
    func cleanLast() {
        if tokens.last?.range.length == 0 {
            tokens.removeLast()
        }
    }
    
    func increaseLastTokenLength(by len: Int = 1) {
        tokens[tokens.count - 1].range.length += len
    }
    
    public func applyTheme(_ attributedString: NSMutableAttributedString, at loc: Int, inSelectionScope: Bool = false) {
        let style = MutableParagraphStyle()
        
        attributedString.setAttributes(nil, range: NSRange(location: loc, length: length))
        
        for token in tokens {
            for scope in token.scopes {
                for attr in scope.attributes {
                    if let lineAttr = attr as? LineThemeAttribute {
                        lineAttr.apply(to: style, inSelectionScope: inSelectionScope)
                    }
                    else if let tokenAttr = attr as? TokenThemeAttribute {
                        tokenAttr.apply(to: attributedString, withRange: NSRange(location: loc + token.range.location, length: token.range.length), inSelectionScope: inSelectionScope)
                    }
                    
                    else {
                        print("Warning: ThemeAttribute with key \(attr.key) does not conform to either LineThemeAttribute or TokenThemeAttribtue so it will not be applied.")
                    }
                }
            }
        }
        
        attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: loc, length: length))
    }
}
