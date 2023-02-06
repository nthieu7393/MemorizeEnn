//
//  BaseViewController.swift
//  Quizzie
//
//  Created by hieu nguyen on 03/11/2022.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    var presenter: BasePresenter?
    var rightBarButtonItems: [UIBarButtonItem]? {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        displayBackBarItemIfNeed()
        displayRightBarItems()
        setupFontText()
        view.backgroundColor = Colors.mainBackground
        navigationController?.navigationBar.barTintColor = Colors.mainBackground
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Colors.mainText!
        ]
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(screenOnTouch(_:))
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func screenOnTouch(_ gesture: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            layoutIfKeyboardShow(keyboardSize: keyboardSize.cgRectValue)
        }
    }

    func layoutIfKeyboardShow(keyboardSize: CGRect) {}

    @objc
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            layoutIfKeyboardHide(keyboardSize: keyboardSize.cgRectValue)
        }
    }

    func layoutIfKeyboardHide(keyboardSize: CGRect) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = !isPush
    }
    
    private func displayBackBarItemIfNeed() {
        guard isPush else { return }
        let backButton: UIButton = UIButton()
        backButton.setImage(Icons.backIcon, for: UIControl.State())
        backButton.addTarget(
            self,
            action: #selector(backBarItemOnTap(_:)),
            for: UIControl.Event.touchUpInside
        )
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func displayRightBarItems() {
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    @objc private func backBarItemOnTap(_ sender: Any) {
        backToPreviousScreen()
    }
    
    func backToPreviousScreen() {
        coordinator?.back(animated: true)
    }
    
    func setupFontText() {}

    private var isPush: Bool {
        if let index = coordinator?.child.firstIndex(of: self), index > 0 {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        return false
    }
}

extension BaseViewController: BaseViewProtocol {

    func showSuccessAlert(msg: String) {
        let alert = UIAlertController(title: "Success", message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Close", style: .destructive)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

    func showErrorAlert(msg: String) {
        let alert = UIAlertController(title: "Failed", message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Close", style: .destructive)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

    func showLoadingIndicator() {
        SVProgressHUD.show()
    }

    func dismissLoadingIndicator() {
        SVProgressHUD.dismiss()
    }

    func showResultAlert(error: Error?, message: String? = nil) {
        if let uwrError = error {
            showErrorAlert(msg: uwrError.localizedDescription)
        } else {
            showSuccessAlert(msg: message ?? "")
        }
    }
}
