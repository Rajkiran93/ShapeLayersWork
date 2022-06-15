//
//  ViewController.swift
//  ShapeLayersWork
//
//  Created by Don Mag on 6/14/22.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Menu"
		
		let stack: UIStackView = {
			let v = UIStackView()
			v.axis = .vertical
			v.spacing = 20
			v.translatesAutoresizingMaskIntoConstraints = false
			return v
		}()

		["Layers"].forEach { str in
			let b = UIButton()
			b.setTitle(str, for: [])
			b.setTitleColor(.white, for: .normal)
			b.setTitleColor(.lightGray, for: .highlighted)
			b.backgroundColor = .systemBlue
			b.addTarget(self, action: #selector(btnTap(_:)), for: .touchUpInside)
			stack.addArrangedSubview(b)
		}
		
		view.addSubview(stack)
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			stack.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			stack.topAnchor.constraint(equalTo: g.topAnchor, constant: 80.0),
			stack.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.6),
		])
		
	}

	@objc func btnTap(_ sender: UIButton) {
		if let t = sender.currentTitle {
			switch t {
			case "Layers":
				let vc = ManyLayersViewController()
				self.navigationController?.pushViewController(vc, animated: true)
			default:
				()
			}
		}
	}

}

class BaseViewController: UIViewController, UIScrollViewDelegate {
	
	let scrollView: UIScrollView = {
		let v = UIScrollView()
		v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		v.contentInsetAdjustmentBehavior = .never
		return v
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		// add scroll view to self.view
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		
		let safeG = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			
			// scroll view Top/Leading/Trailing/Bottom to safe area
			scrollView.topAnchor.constraint(equalTo: safeG.topAnchor, constant: 40.0),
			scrollView.leadingAnchor.constraint(equalTo: safeG.leadingAnchor, constant: 40.0),
			scrollView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: -40.0),
			scrollView.bottomAnchor.constraint(equalTo: safeG.bottomAnchor, constant: -40.0),
			
		])
		
		scrollView.minimumZoomScale = 0.25
		scrollView.maximumZoomScale = 10.0
		
		// so we can see the scroll view frame
		scrollView.layer.borderWidth = 2
		scrollView.layer.borderColor = UIColor.red.cgColor
		
	}
	
}
class ManyLayersViewController: BaseViewController {
	
	let pathView: UIView = {
		let v = UIView()
		return v
	}()
	
	let vW: CGFloat = 3508
	let vH: CGFloat = 2480
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Layers"
		
		// add pathView to the scroll view
		pathView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(pathView)
		
		let contentG = scrollView.contentLayoutGuide
		
		NSLayoutConstraint.activate([
			
			// pathView Top/Leading/Trailing/Bottom to scroll view's CONTENT GUIDE
			pathView.topAnchor.constraint(equalTo: contentG.topAnchor, constant: 0.0),
			pathView.leadingAnchor.constraint(equalTo: contentG.leadingAnchor, constant: 0.0),
			pathView.trailingAnchor.constraint(equalTo: contentG.trailingAnchor, constant: 0.0),
			pathView.bottomAnchor.constraint(equalTo: contentG.bottomAnchor, constant: 0.0),
			
			pathView.widthAnchor.constraint(equalToConstant: vW),
			pathView.heightAnchor.constraint(equalToConstant: vH),
			
		])
		
		scrollView.delegate = self
		
		// so we can see the scroll view frame
		scrollView.layer.borderWidth = 2
		scrollView.layer.borderColor = UIColor.red.cgColor
		
		let colors: [UIColor] = [
			.red, .green, .blue,
			.cyan, .magenta, .yellow
		]
		
		let alphaArray: [String] = AlphaPaths.shared.charsArray
		let lh: CGFloat = AlphaPaths.shared.lineHeight
		
		let pad: CGFloat = 2.0
		var y: CGFloat = pad
		var x: CGFloat = pad
		var cIDX: Int = 0

		while y <= vW - (lh + pad) {
			if let pth = AlphaPaths.shared.paths[alphaArray[cIDX % alphaArray.count]] {
				let sl = CAShapeLayer()
				sl.strokeColor = UIColor.gray.cgColor
				sl.fillColor = colors[cIDX % colors.count].cgColor
				if x + pth.boundingBoxOfPath.origin.x + pth.boundingBoxOfPath.width >= vW - pad {
					x = pad
					y += lh
				}
				var tr = CGAffineTransform(translationX: x, y: y)
				//sl.frame.origin = CGPoint(x: x, y: y)
				x += pth.boundingBoxOfPath.origin.x + pth.boundingBoxOfPath.width + pad
				sl.path = pth.copy(using: &tr)
				pathView.layer.addSublayer(sl)
			}
			cIDX += 1
		}

		pathView.clipsToBounds = true
		
		print("Num Sublayers:", pathView.layer.sublayers?.count ?? 0)
		
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return pathView
	}
	
}

