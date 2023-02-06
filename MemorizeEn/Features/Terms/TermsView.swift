//
//  TermsView.swift
//  Quizzie
//
//  Created by hieu nguyen on 19/11/2022.
//

import UIKit

protocol TermsView: BaseViewProtocol {

    func displayTerms(terms: [Card])
    func displayCard(card: Card?, at cell: TermTableCell, display: Bool)
}
