//
//  TopTableViewCell.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

final class TopTableViewCell: UITableViewCell {

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
}
