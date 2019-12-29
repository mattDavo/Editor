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
    
    // Inspiration from : https://instagram-engineering.com/building-type-mode-for-stories-on-ios-and-android-8804e927feba
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        defer {
            super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        }
        
        guard let textStorage = textStorage else {
            return
        }
        
        // We are guaranteed that the glyph range will all be in one text container
        guard let textContainer = textContainer(forGlyphAt: glyphsToShow.location, effectiveRange: nil) else {
            return
        }
        
        textStorage.enumerateAttribute(BackgroundColorThemeAttribute.RoundedBackground.Key, in: glyphsToShow, using: { (value, range, stop) in
            // Check we've got a color
            guard let roundedBackground = value as? BackgroundColorThemeAttribute.RoundedBackground else {
                return
            }
            
            if roundedBackground.coloringStyle == .textOnly {
                var rectCount = -1
                guard let rectArray = self.rectArray(forCharacterRange: range, withinSelectedCharacterRange: range, in: textContainer, rectCount: &rectCount) else {
                    fatalError("Failed to received rect array for characterRange: \(range), within selected character range: \(range), in text container: \(textContainer)")
                }
                
                guard rectCount != -1 else {
                    fatalError("Failed to receive rect array count.")
                }
                
                let lineHeight = lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil).height
                let cornerRadius = lineHeight * roundedBackground.roundingStyle.rawValue / 2
                
                // Adjust for text container insets
                for i in 0..<rectCount {
                    rectArray[i] = rectArray[i].offsetBy(dx: origin.x, dy: origin.y)
                    rectArray[i] = rectArray[i].insetBy(dx: -5, dy: 0)
                }
                
                self.fillRoundedBackgroundRectArray(rectArray, count: rectCount, color: roundedBackground.color, cornerRadius: cornerRadius)
            }
            else if roundedBackground.coloringStyle == .line {

                var rect = lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil)
                let cornerRadius = rect.height * roundedBackground.roundingStyle.rawValue / 2
                
                // Adjust for text container insets
                rect = rect.offsetBy(dx: origin.x, dy: origin.y)
                rect = rect.insetBy(dx: -5, dy: 0)
                
                self.fillRoundedBackgroundRectArray(rect, color: roundedBackground.color, cornerRadius: cornerRadius)
            }
        })
    }
    
    // Adapted from: https://stackoverflow.com/a/44303971
    func fillRoundedBackgroundRectArray(_ rectArray: UnsafePointer<NSRect>, count rectCount: Int, color: NSColor, cornerRadius: CGFloat) {
        
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
    
    func fillRoundedBackgroundRectArray(_ rect: NSRect, color: NSColor, cornerRadius: CGFloat) {
        
        let path = CGMutablePath()

        path.addRect(rect.insetBy(dx: cornerRadius, dy: cornerRadius))

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
