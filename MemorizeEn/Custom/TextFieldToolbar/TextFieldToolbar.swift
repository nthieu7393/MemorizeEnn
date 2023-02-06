//
//  TextFieldToolbar.swift
//  Quizzie
//
//  Created by hieu nguyen on 06/11/2022.
//

import UIKit

class TextFieldToolbar: UIView {

    @IBOutlet private weak var textField: UITextField!

    @IBAction func doneBtnOnTap(_ sender: UIButton) {
        textFieldEndEditing?(textfield.text)
        textField.endEditing(true)
    }

    var textFieldEndEditing: ((String?) -> Void)?

    var placeholder: String? {
        didSet {
            textfield.placeholder = placeholder
        }
    }

    var textfield: UITextField {
        return textField
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        startObservingNotification()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startObservingNotification()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.returnKeyType = .done
        backgroundColor = Colors.mainBackground
    }

    private func startObservingNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    func becomeFirstResponser(
        initialString: String,
        endEditing: @escaping (String?) -> Void
    ) {
        textfield.text = initialString
        textfield.becomeFirstResponder()
        textFieldEndEditing = endEditing
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        isHidden = false
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        textField.resignFirstResponder()
        textField.text = ""
        isHidden = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextFieldToolbar: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldEndEditing?(textField.text)
        return true
    }
}
