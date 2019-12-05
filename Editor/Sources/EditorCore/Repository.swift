//
//  Repository.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 26/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

public class Repository {
    
    var patterns: [String: Pattern]
    
    public init(patterns: [String: Pattern]) {
        self.patterns = patterns
    }
}
