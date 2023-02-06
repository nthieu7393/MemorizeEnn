//
//  UIView+Extensions.swift
//  Quizzie
//
//  Created by hieu nguyen on 04/11/2022.
//

import UIKit

extension UIView {

    class func fromNib<T: UIView>() -> T? {
       return Bundle(for: T.self)
            .loadNibNamed(
                String(describing: T.self),
                owner: nil,
                options: nil)![0] as? T
    }

    func addCornerRadius() {
        layer.masksToBounds = true
        layer.cornerRadius = Constants.borderRadius
    }

    func addDashline(color: UIColor? = nil, cornerRadius: CGFloat = 0) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = Colors.active?.cgColor
        viewBorder.frame = bounds
        viewBorder.lineDashPattern = [8, 4]
        viewBorder.lineWidth = 5
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        viewBorder.masksToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.addSublayer(viewBorder)
    }

    func addLineBorder(color: UIColor? = nil, cornerRadius: CGFloat = 0) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = color?.cgColor ?? Colors.active?.cgColor
        viewBorder.frame = bounds
        viewBorder.lineWidth = 3
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        viewBorder.masksToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.addSublayer(viewBorder)
    }
}
