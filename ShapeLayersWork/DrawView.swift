//
//  DrawView.swift
//  ShapeLayersWork
//
//  Created by Don Mag on 6/14/22.
//

import UIKit

class DrawView: UIView {
	var paths: [MyPath] = []
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() {
		
	}
	func addPath(_ p: MyPath) {
		paths.append(p)
		setNeedsDisplay()
	}
	override func draw(_ rect: CGRect) {
		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(UIColor(white: 0.95, alpha: 1.0).cgColor)
			context.fill(rect)
			var i: Int = 0
			paths.forEach { p in
				if let pth = p.pth {
					if pth.boundingBoxOfPath.intersects(rect) {
						i += 1
						context.addPath(pth)
						if p.fillColor != .clear {
							context.setFillColor(p.fillColor.cgColor)
						}
						if p.lineWidth != 0 && p.strokeColor != .clear {
							context.addPath(pth)
							context.setLineCap(p.lineCap)
							context.setLineJoin(p.lineJoin)
							context.setLineWidth(p.lineWidth)
							context.setStrokeColor(p.strokeColor.cgColor)
						}
						context.drawPath(using: .fillStroke)
					}
				}
			}
			print("Drew \(i) paths")
		}
	}
}
