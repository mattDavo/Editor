//
//  EditorLayoutManager.swift
//  
//
//  Created by Matthew Davidson on 6/12/19.
//

import Foundation
import EditorCore

#if os(macOS)
import Cocoa

class EditorLayoutManager: NSLayoutManager {
    
    // Adapted from: https://stackoverflow.com/a/44303971
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<NSRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: NSColor) {
        
        if textStorage?.attributes(at: charRange.location, effectiveRange: nil)[NSAttributedString.Key(rawValue: "isBackgroundColorRounded")] as? Bool ?? false == false {
            super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
            return
        }
        
        let cornerRadius: CGFloat = 5
        let path = CGMutablePath()

        if rectCount == 1 || (rectCount == 2 && (rectArray[1].maxX < rectArray[0].maxX)) {
            path.addRect(rectArray[0].insetBy(dx: cornerRadius, dy: cornerRadius))

            if rectCount == 2 {
                path.addRect(rectArray[1].insetBy(dx: cornerRadius, dy: cornerRadius))
            }

        }
        else {
            let lastRect = rectCount - 1

            path.move(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].minY + cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[0].minY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.closeSubpath()

        }

        color.set()
        
        let cgContext = NSGraphicsContext.current?.cgContext
        cgContext?.setLineWidth(cornerRadius * 2.0)
        cgContext?.setLineJoin(.round)

        cgContext?.setAllowsAntialiasing(true)
        cgContext?.setShouldAntialias(true)

        cgContext?.addPath(path)
        cgContext?.drawPath(using: .fillStroke)
    }
}

#endif
