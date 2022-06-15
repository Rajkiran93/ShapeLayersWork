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

		["Example"].forEach { str in
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
			case "Example":
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

	let detailView: UIView = {
		let v = UIView()
		v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		v.layer.cornerRadius = 8.0
		v.layer.shadowColor = UIColor.black.cgColor
		v.layer.shadowRadius = 4
		v.layer.shadowOpacity = 0.6
		v.layer.shadowOffset = CGSize(width: 0, height: 3)
		return v
	}()
	let detailLabel: UILabel = {
		let v = UILabel()
		v.numberOfLines = 0
		v.font = .systemFont(ofSize: 14, weight: .light)
		return v
	}()
	
	let loadingView: LoadingView = {
		let v = LoadingView()
		return v
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		[loadingView, scrollView, detailView, detailLabel].forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
		}

		detailView.addSubview(detailLabel)
		view.addSubview(detailView)

		view.addSubview(scrollView)
		
		view.addSubview(loadingView)
		
		let safeG = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			
			detailLabel.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 12.0),
			detailLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 12.0),
			detailLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -12.0),
			detailLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -12.0),
			
			detailView.leadingAnchor.constraint(equalTo: safeG.leadingAnchor, constant: 40.0),
			detailView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: -40.0),
			detailView.bottomAnchor.constraint(equalTo: safeG.bottomAnchor, constant: -20.0),

			// scroll view Top/Leading/Trailing/Bottom to safe area
			scrollView.topAnchor.constraint(equalTo: safeG.topAnchor, constant: 20.0),
			scrollView.leadingAnchor.constraint(equalTo: safeG.leadingAnchor, constant: 20.0),
			scrollView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: -20.0),
			scrollView.bottomAnchor.constraint(equalTo: detailView.topAnchor, constant: -20.0),

			loadingView.centerXAnchor.constraint(equalTo: safeG.centerXAnchor),
			loadingView.widthAnchor.constraint(equalTo: safeG.widthAnchor, multiplier: 0.75),
			loadingView.topAnchor.constraint(equalTo: safeG.topAnchor, constant: 100.0),
		])

		scrollView.minimumZoomScale = 0.5
		scrollView.maximumZoomScale = 10.0
		
//		// so we can see the scroll view frame
//		scrollView.layer.borderWidth = 2
//		scrollView.layer.borderColor = UIColor.red.cgColor
		
		scrollView.alpha = 0.0
		detailView.alpha = 0.0
		
	}
	
}

class ManyLayersViewController: BaseViewController {
	
	let pathView: UIView = {
		let v = UIView()
		v.clipsToBounds = true
		return v
	}()

	let vW: CGFloat = 3508
	let vH: CGFloat = 2480
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Layers"
		
		pathView.translatesAutoresizingMaskIntoConstraints = false
		
		scrollView.addSubview(pathView)
		
		let contentG = scrollView.contentLayoutGuide
		
		NSLayoutConstraint.activate([
			
			pathView.topAnchor.constraint(equalTo: contentG.topAnchor, constant: 0.0),
			pathView.leadingAnchor.constraint(equalTo: contentG.leadingAnchor, constant: 0.0),
			pathView.trailingAnchor.constraint(equalTo: contentG.trailingAnchor, constant: 0.0),
			pathView.bottomAnchor.constraint(equalTo: contentG.bottomAnchor, constant: 0.0),
			
			pathView.widthAnchor.constraint(equalToConstant: vW),
			pathView.heightAnchor.constraint(equalToConstant: vH),
			
		])
		
		scrollView.delegate = self
		
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.generateLayers()
	}
	func generateLayers() {
		let colors: [UIColor] = [
			.red, .green, .magenta, .blue,
			.orange, .cyan,
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
				sl.lineWidth = 0.5
				if x + pth.boundingBoxOfPath.origin.x + pth.boundingBoxOfPath.width >= vW - pad {
					x = pad
					y += lh
				}
				var tr = CGAffineTransform(translationX: x, y: y)
				x += pth.boundingBoxOfPath.origin.x + pth.boundingBoxOfPath.width + pad
				sl.path = pth.copy(using: &tr)
				pathView.layer.addSublayer(sl)
			}
			cIDX += 1
		}
		x = 280
		y = 240
		["L", "A", "Y", "E", "R", "S"].forEach { s in
			if let pth = AlphaPaths.shared.paths[s] {
				let sl = CAShapeLayer()
				sl.strokeColor = UIColor.systemRed.cgColor
				sl.fillColor = UIColor.systemBlue.cgColor
				sl.lineWidth = 2
				var tr = CGAffineTransform(translationX: x, y: y).rotated(by: .pi * 0.25).scaledBy(x: 4.0, y: 8.0)
				sl.path = pth.copy(using: &tr)
				pathView.layer.addSublayer(sl)
				x += 60
				y += 120
			}
			cIDX += 1
		}

		// let's add some translucent shapes just for the heck of it
		let bez = UIBezierPath()
		var pt: CGPoint = CGPoint(x: 20, y: 0)
		bez.move(to: pt)
		pt.x += 20
		pt.y += 20
		bez.addLine(to: pt)
		pt.x -= 10
		pt.y += 20
		bez.addLine(to: pt)
		pt.x -= 20
		bez.addLine(to: pt)
		pt.x -= 10
		pt.y -= 20
		bez.addLine(to: pt)
		bez.close()
		x = 200
		y = 1200
		for i in 10...15 {
			let sl = CAShapeLayer()
			sl.fillColor = (UIColor.yellow.withAlphaComponent(0.5)).cgColor
			sl.strokeColor = UIColor.systemGreen.cgColor
			var tr = CGAffineTransform(translationX: x, y: y).scaledBy(x: CGFloat(i), y: CGFloat(i))
			x += 100
			sl.path = bez.cgPath.copy(using: &tr)
			pathView.layer.addSublayer(sl)
		}

		detailLabel.text = "\(pathView.layer.sublayers?.count ?? 0) Shape Layers from \(alphaArray.count + 1) paths" +
		"\n" +
		"Shape Path Points - min: \(AlphaPaths.shared.minPoints) max: \(AlphaPaths.shared.maxPoints)" +
		"\n" +
		"Shape Path Curves - min: \(AlphaPaths.shared.minCurves) max: \(AlphaPaths.shared.maxCurves)"

		self.scrollView.alpha = 1.0
		self.detailView.alpha = 1.0
		self.loadingView.removeFromSuperview()
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return pathView
	}
	
}

class LoadingView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() {
		let label: UILabel = {
			let v = UILabel()
			v.textAlignment = .center
			v.text = "Generating Shape Layers"
			return v
		}()
		let spinner: UIActivityIndicatorView = {
			let v = UIActivityIndicatorView(style: .large)
			return v
		}()
		[spinner, label].forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
			addSubview(v)
		}
		let g = layoutMarginsGuide
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: g.topAnchor),
			label.leadingAnchor.constraint(equalTo: g.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: g.trailingAnchor),
			spinner.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12.0),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4.0),
		])
		layer.cornerRadius = 12.0
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.5
		layer.shadowRadius = 5.0
		layer.shadowOffset = CGSize(width: 0, height: 4)
		backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		spinner.startAnimating()
	}
}
