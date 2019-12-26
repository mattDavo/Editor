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
    
    /// Finds the text containers and the ranges it contains of a given range.
    private func getTextContainersRanges(forRange range: NSRange) -> [(NSRange, NSTextContainer)] {
        var ranges = [(NSRange, NSTextContainer)]()
        // Holder for the effective range
        var effectiveRange = NSRange(location: NSNotFound, length: 0)
        // The minimum range that would mean there are no more text containers holding characters in the given range.
        var targetRange = range
        while true {
            guard let textContainer = textContainer(forGlyphAt: range.location, effectiveRange: &effectiveRange) else {
                fatalError("Unexpectedly received nil for textContainer when applying rounded background.")
            }
            
            if effectiveRange.location == NSNotFound {
                fatalError("Failed to retrieve range of textContainer when applying rounded background.")
            }
            
            // Not all of the target range is in this text container
            if targetRange.upperBound > effectiveRange.upperBound {
                ranges.append((
                    NSRange(targetRange.location..<effectiveRange.upperBound),
                    textContainer
                ))
                
                // Update target range and reset effective range
                targetRange = NSRange(effectiveRange.upperBound..<targetRange.upperBound)
                effectiveRange = NSRange(location: NSNotFound, length: 0)
            }
            // All of the target range is in this text container
            else {
                ranges.append((targetRange, textContainer))
                break
            }
        }
        
        return ranges
    }
    
    // Inspiration from : https://instagram-engineering.com/building-type-mode-for-stories-on-ios-and-android-8804e927feba
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        
        guard let textStorage = textStorage else {
            return
        }
        
        textStorage.enumerateAttribute(BackgroundColorThemeAttribute.RoundedBackground.Key, in: glyphsToShow, using: { (value, range, stop) in
            // Check we've got a color
            guard let roundedBackground = value as? BackgroundColorThemeAttribute.RoundedBackground else {
                return
            }
            
            // Get the text containers for the range
            let textContainerRanges = getTextContainersRanges(forRange: range)
            
            for (range, textContainer) in textContainerRanges {
                var rectCount = -1
                guard let rectArray = self.rectArray(forCharacterRange: range, withinSelectedCharacterRange: range, in: textContainer, rectCount: &rectCount) else {
                    fatalError("Failed to received rect array for characterRange: \(range), within selected character range: \(range), in text container: \(textContainer)")
                }
                
                guard rectCount != -1 else {
                    fatalError("Failed to receive rect array count.")
                }
                
                let lineHeight = lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil).height
                let cornerRadius = lineHeight * roundedBackground.style.rawValue / 2
                
                // Adjust for text container insets
                for i in 0..<rectCount {
                    rectArray[i] = rectArray[i].offsetBy(dx: origin.x, dy: origin.y)
                    rectArray[i] = rectArray[i].insetBy(dx: -5, dy: 0)
                }
                
                self.fillRoundedBackgroundRectArray(rectArray, count: rectCount, color: roundedBackground.color, cornerRadius: cornerRadius)
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
}

#endif
