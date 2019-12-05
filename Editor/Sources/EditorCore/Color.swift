//
//  Color.swift
//  TM-Tokenizer
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(macOS)
import Cocoa
public typealias Color = NSColor
#endif
