//
//  ThemeAttribtue.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public protocol ThemeAttribute {
    
    /// Unique key for this type of attribute
    var key: String { get }
    
    func apply(to attrStr: NSMutableAttributedString, withLineRange lineRange: NSRange, tokenRange: NSRange)
}
