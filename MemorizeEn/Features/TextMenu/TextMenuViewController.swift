//
//  TextMenuViewController.swift
//  Quizzie
//
//  Created by hieu nguyen on 08/01/2023.
//

import UIKit

class TextMenuViewController: BaseViewController, Storyboarded {

    var menuItems: [String]!
    var selectedItemIndex: Int?
    var didSelectHandler: ((Int) -> Void)!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TextMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TextMenuTableViewCell.self),
            for: indexPath
        ) as? TextMenuTableViewCell else {
            return UITableViewCell()
        }
        cell.setText(
            menuItems[indexPath.row],
            shouldHighlight: selectedItemIndex == indexPath.row
        )
        return cell
    }
}

extension TextMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectHandler(indexPath.row)
    }
}
