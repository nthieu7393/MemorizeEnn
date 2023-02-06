//
//  UnderlineTextField.swift
//  Quizzie
//
//  Created by hieu nguyen on 24/01/2023.
//

import UIKit

class UnderlineTextField: UITextField {

    private var hairlineLayer: CALayer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    private func layout() {
        backgroundColor = UIColor.clear
        font = Fonts.regularText
        textColor = Colors.mainText

        hairlineLayer = CALayer()
        hairlineLayer?.backgroundColor = UIColor.green.cgColor
        layer.addSublayer(hairlineLayer!)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var hairlineHeight: CGFloat = 0
        if isFirstResponder {
            hairlineLayer?.backgroundColor = Colors.active?.cgColor
            hairlineHeight = 2
        } else {
            hairlineLayer?.backgroundColor = Colors.unFocused?.cgColor
            hairlineHeight = 3/UIScreen.main.scale
        }
        hairlineLayer?.frame = CGRect(
            x: 0,
            y: bounds.height - hairlineHeight,
            width: bounds.width,
            height: hairlineHeight
        )
    }
}
