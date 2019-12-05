//
//  ThemeAttribtue.swift
//  
//
//  Created by Matthew Davidson on 4/12/19.
//

import Foundation

public protocol ThemeAttribute {
    
    var key: String { get }
    
    func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange)
}
