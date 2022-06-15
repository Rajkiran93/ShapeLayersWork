//
//  AlphaPaths.swift
//  ShapeLayersWork
//
//  Created by Don Mag on 6/14/22.
//

import UIKit

extension CGPath {
	
	/// this is a computed property, it will hold the points we want to extract
	var points: [CGPoint] {
		
		/// this is a local transient container where we will store our CGPoints
		var arrPoints: [CGPoint] = []
		
		// applyWithBlock lets us examine each element of the CGPath, and decide what to do
		self.applyWithBlock { element in
			
			switch element.pointee.type
			{
			case .moveToPoint, .addLineToPoint:
				arrPoints.append(element.pointee.points.pointee)
				
			case .addQuadCurveToPoint:
				arrPoints.append(element.pointee.points.pointee)
				arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
				
			case .addCurveToPoint:
				arrPoints.append(element.pointee.points.pointee)
				arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
				arrPoints.append(element.pointee.points.advanced(by: 2).pointee)
				
			default:
				break
			}
		}
		
		// We are now done collecting our CGPoints and so we can return the result
		return arrPoints
		
	}

	var pointsCount: Int {
		
		var count: Int = 0
		
		// applyWithBlock lets us examine each element of the CGPath, and decide what to do
		self.applyWithBlock { element in
			
			switch element.pointee.type
			{
			case .moveToPoint, .addLineToPoint:
				count += 1
				
			case .addQuadCurveToPoint:
				count += 2
				
			case .addCurveToPoint:
				count += 3
				
			default:
				break
			}
		}
		
		// We are now done collecting our CGPoints and so we can return the result
		return count
		
	}

	var curvesCount: Int {
		
		var count: Int = 0
		
		// applyWithBlock lets us examine each element of the CGPath, and decide what to do
		self.applyWithBlock { element in
			
			switch element.pointee.type
			{
			case .addQuadCurveToPoint, .addCurveToPoint:
				count += 1
				
			default:
				break
			}
		}
		
		// We are now done collecting our CGPoints and so we can return the result
		return count
		
	}
}

// dictionary of CGPaths for characters " " - "~"
class AlphaPaths: NSObject {

	static let shared = AlphaPaths()
	var paths: [String : CGPath] = [:]
	var charsArray: [String] = []
	var lineHeight: CGFloat = 0
	var minPoints: Int = 999999
	var maxPoints: Int = 0
	var minCurves: Int = 999999
	var maxCurves: Int = 0

	private override init() {
		// use 24-point Times New Roman font
		guard let font = UIFont(name: "Times New Roman", size: 24) else {
			fatalError("Could not create font!!!")
		}
		
		lineHeight = font.lineHeight
		
		let unicodeScalarRange: ClosedRange<Unicode.Scalar> = "!" ... "~"
		let unicodeScalarValueRange: ClosedRange<UInt32> = unicodeScalarRange.lowerBound.value ... unicodeScalarRange.upperBound.value
		let unicodeScalarArray: [Unicode.Scalar] = unicodeScalarValueRange.compactMap(Unicode.Scalar.init)
		charsArray = unicodeScalarArray.map(String.init)
		
		var a: [UniChar] = unicodeScalarValueRange.map(UniChar.init)
		var glyphs = [CGGlyph](repeatElement(0, count: a.count))
		let gotGlyphs = CTFontGetGlyphsForCharacters(font, &a, &glyphs, a.count)

		if !gotGlyphs {
			fatalError("Could not get glyphs for font characters!!!")
		}

		for (c, g) in zip(charsArray, glyphs) {
			if let cgpath = CTFontCreatePathForGlyph(font, g, nil) {
				var tr = CGAffineTransform(scaleX: 1.0, y: -1.0).translatedBy(x: 0, y: -(font.ascender + 0.0))
				if let p = cgpath.copy(using: &tr) {
					paths[c] = p
					var np = p.pointsCount
					minPoints = min(minPoints, np)
					maxPoints = max(maxPoints, np)
					np = p.curvesCount
					minCurves = min(minCurves, np)
					maxCurves = max(maxCurves, np)
				}
			}
		}

	}

}

