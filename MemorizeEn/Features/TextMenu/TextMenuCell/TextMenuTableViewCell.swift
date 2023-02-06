//
//  TextMenuTableViewCell.swift
//  Quizzie
//
//  Created by hieu nguyen on 08/01/2023.
//

import UIKit

class TextMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = Fonts.regularText
        label.textColor = UIColor.gray
    }

    func setText(_ text: String, shouldHighlight: Bool) {
        label.text = text
        if shouldHighlight {
            label.font = Fonts.boldText
        }
    }
}
