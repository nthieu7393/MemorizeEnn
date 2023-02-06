//
//  UnderlineTextView.swift
//  Quizzie
//
//  Created by hieu nguyen on 24/01/2023.
//

import UIKit

class UnderlineTextView: UITextView {

    private var hairlineLayer: CALayer?
    var forwardDelegate: UITextViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
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

    var hairlineHeight: CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()


        if isFirstResponder {
//            hairlineLayer?.backgroundColor = Colors.active?.cgColor
//            hairlineHeight = 2
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

extension UnderlineTextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        forwardDelegate?.textViewDidChange?(textView)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        forwardDelegate?.textViewDidBeginEditing?(textView)
        hairlineLayer?.backgroundColor = Colors.active?.cgColor
        hairlineHeight = 2
        hairlineLayer?.frame = CGRect(
            x: 0,
            y: bounds.height - hairlineHeight,
            width: bounds.width,
            height: hairlineHeight)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        hairlineLayer?.backgroundColor = Colors.unFocused?.cgColor
        hairlineHeight = 3 / UIScreen.main.scale
        hairlineLayer?.frame = CGRect(
            x: 0,
            y: bounds.height - hairlineHeight,
            width: bounds.width,
            height: hairlineHeight)
    }
}
