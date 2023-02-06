//
//  TermsViewController.swift
//  Quizzie
//
//  Created by hieu nguyen on 19/11/2022.
//

import UIKit
import DropDown

class TermsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var terms: [Card]?

    private var termsPresenter: TermsPresenter? {
        return presenter as? TermsPresenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        termsPresenter?.getAllTerms()
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addTapped(_:))),
            UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(save(_:)))
        ]
    }
    
    @objc func addTapped(_ gesture: Any) {
        let term = WordsApiWordItem()
        terms?.insert(term, at: 0)
        termsPresenter?.insertTermToList(term: term)
        tableView.insertRows(
            at: [IndexPath(row: 0, section: 0)],
            with: .automatic
        )
        
    }
    
    @objc func save(_ gesture: Any) {
        termsPresenter?.saveTopic()
        view.endEditing(true)
    }
}

extension TermsViewController: Storyboarded {

}

extension TermsViewController: TermsView {

    func displayTerms(terms: [Card]) {
        self.terms = terms
        tableView.reloadData()
    }
    
    func displayCard(card: Card?, at cell: TermTableCell, display: Bool) {
        cell.setCard(term: card, autoDisplay: display)
    }
}

extension TermsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TermTableCell.self),
            for: indexPath) as? TermTableCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setCard(term: terms?[indexPath.row], autoDisplay: true)
        return cell
    }
}

extension TermsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TermsViewController: TermTableCellProtocol {

    func updateHeightOfRow(_ cell: TermTableCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
//            if let indexPath = tableView.indexPath(for: cell) {
//                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
//            }
        }
    }

    func cardEditingChanged(
        _ cell: TermTableCell,
        _ card: Card,
        loadDataOfCard: Bool,
        autoFill: Bool) {
        if loadDataOfCard {
            termsPresenter?.autoFillDataOfTerm(
                card: card,
                at: cell,
                display: autoFill
            )
        }
        termsPresenter?.updateListOfCards(term: card)
    }
}
