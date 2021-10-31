//
//  TabCollectionViewCell.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

final class TabCollectionViewCell: UICollectionViewCell {

    static let estimatedSize = CGSize(width: 100.0, height: 49.0)

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!

    /// titleLabelのbottom + マージン
    var underlineOffsetY: CGFloat {
        titleLabel.frame.origin.y + titleLabel.frame.size.height + CGFloat(8)
    }
}
