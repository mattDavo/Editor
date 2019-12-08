//
//  WindowController.swift
//  macOS Application
//
//  Created by Matthew Davidson on 8/12/19.
//  Copyright © 2019 Matt Davidson. All rights reserved.
//

import Foundation
import Cocoa

class WindowController: NSWindowController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        window?.setFrameAutosaveName(NSWindow.FrameAutosaveName(stringLiteral: "Editor"))
    }
}
