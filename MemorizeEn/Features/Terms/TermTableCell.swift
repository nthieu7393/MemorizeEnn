//
//  TermTableCell.swift
//  Quizzie
//
//  Created by hieu nguyen on 19/11/2022.
//

import UIKit
import DropDown

protocol TermTableCellProtocol: AnyObject {
    
    func updateHeightOfRow(_ cell: TermTableCell, _ textView: UITextView)
    func cardEditingChanged(
        _ cell: TermTableCell,
        _ card: Card,
        loadDataOfCard: Bool,
        autoFill: Bool)
}

class TermTableCell: UITableViewCell {

    @IBOutlet private weak var definitionTextView: UnderlineTextView!
    @IBOutlet private weak var exampleTextView: UnderlineTextView!
    @IBOutlet private weak var termTextField: UnderlineTextField!
    @IBOutlet private weak var lexicalCategoryButton: UIButton!
    @IBOutlet private weak var searchTextWrapperView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var termLabel: UILabel!
    @IBOutlet private weak var definitionLabel: UILabel!
    @IBOutlet private weak var exampleLabel: UILabel!

    private var term: Card?
    var card: Card? { return term }
    weak var delegate: TermTableCellProtocol?
    let definitionDropdown = DropDown()
    let exampleDropdown = DropDown()

    lazy private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .gray
        return indicator
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        loadingIndicator.frame = searchTextWrapperView.bounds
        searchTextWrapperView.addSubview(loadingIndicator)
        termTextField.addTarget(
            self,
            action: #selector(termTfEditingChanged(_:)),
            for: .editingChanged)
        setupLabels()
        containerView.backgroundColor = Colors.cellBackground
        containerView.addCornerRadius()
    }

    private func setupLabels() {
        termLabel.text = Localizations.term
        termLabel.font = Fonts.subtitle
        termLabel.textColor = Colors.mainText
        definitionLabel.text = Localizations.definition
        definitionLabel.font = Fonts.subtitle
        definitionLabel.textColor = termLabel.textColor
        exampleLabel.text = Localizations.example
        exampleLabel.font = Fonts.subtitle
        exampleLabel.textColor = termLabel.textColor
    }

    private func setupDropdownOfCard() {
        if let listOfDefinition = card?.listOfDefinition {
            createDropdown(dropdown: definitionDropdown, anchorView: definitionTextView) { _, text in
                self.term?.selectedDefinition = text
                self.definitionTextView.text = text
                self.delegate?.cardEditingChanged(self, self.term!, loadDataOfCard: false, autoFill: false)
            }
            definitionDropdown.dataSource = listOfDefinition
        }
        if let listOfExample = card?.listOfExamples {
            createDropdown(dropdown: exampleDropdown, anchorView: exampleTextView) { _, text in
                self.term?.selectedExample = text
                self.exampleTextView.text = text
                self.delegate?.cardEditingChanged(self, self.term!, loadDataOfCard: false, autoFill: false)
            }
            exampleDropdown.dataSource = listOfExample
        }
    }

    private func createDropdown(dropdown: DropDown, anchorView: UIView, selectionAction: @escaping SelectionClosure) {
        dropdown.anchorView = anchorView
        dropdown.dismissMode = .automatic
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(
            x: 0,
            y: (dropdown.anchorView?.plainView.bounds.height)! + 5)
        dropdown.selectionAction = selectionAction
    }
    
    @objc func termTfEditingChanged(_ sender: UITextField) {
        guard var uwrCard = term else { return }
        uwrCard.termDisplay = sender.text ?? ""
        delegate?.cardEditingChanged(
            self,
            uwrCard,
            loadDataOfCard: true,
            autoFill: true)
        startLoading()
    }

    @IBAction func lexicalCategoryButtonOnTap(_ sender: UIButton) {
        
    }
    
    func setCard(term: Card?, autoDisplay: Bool) {
        definitionTextView.forwardDelegate = self
        exampleTextView.forwardDelegate = self
        finishLoading()
        lexicalCategoryButton.isHidden = term?.listOfLexicalCategory?.isEmpty ?? true
        guard let term = term else { return }
        self.term = term
        if autoDisplay {
            termTextField.text = term.termDisplay
            definitionTextView.text = self.term?.selectedDefinition
            exampleTextView.text = term.selectedExample
            lexicalCategoryButton.setTitle(term.selectedLexicalCategory?.rawValue, for: .normal)
        } else {
            setupDropdownOfCard()
        }
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
    }

    private func finishLoading() {
        loadingIndicator.stopAnimating()
    }
}

extension TermTableCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard var uwrCard = term else { return }
        if textView == definitionTextView {
            uwrCard.selectedDefinition = textView.text
            definitionDropdown.show()
        } else if textView == exampleTextView {
            uwrCard.selectedExample = textView.text
            exampleDropdown.show()
        }
        delegate?.updateHeightOfRow(self, textView)
        delegate?.cardEditingChanged(
            self,
            uwrCard,
            loadDataOfCard: false,
            autoFill: false)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let uwrCard = term,
                    uwrCard.listOfDefinition.isEmpty || (uwrCard.listOfExamples?.isEmpty ?? true) else { return }
        delegate?.cardEditingChanged(
            self,
            uwrCard,
            loadDataOfCard: true,
            autoFill: false)
    }
    
    func updateDataOfCard() {
        term?.selectedDefinition = definitionTextView.text
        term?.selectedExample = exampleTextView.text
        delegate?.updateHeightOfRow(self, definitionTextView)
        delegate?.updateHeightOfRow(self, exampleTextView)
        finishLoading()
    }
}
