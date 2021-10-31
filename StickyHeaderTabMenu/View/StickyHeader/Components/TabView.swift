//
//  TabView.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/31.
//

import UIKit

protocol TabViewDelegate: AnyObject {
    func tabView(_ tabView: TabView, didSelectTabAt indexPath: IndexPath)
}

final class TabView: UIView {

    static let underlineHeight = CGFloat(2)

    // MARK: - Properties

    weak var delegate: TabViewDelegate?
    var numberOfTabs: Int {
        return titles.count
    }
    private let underlineColor = UIColor.red
    private var titles = [String]()
    private var underlineView: UIView?

    // MARK: - IBOutlets

    @IBOutlet private weak var tabCollectionView: UICollectionView! {
        willSet {
            newValue.register(
                UINib(
                    nibName: TabCollectionViewCell.identifier,
                    bundle: nil
                ),
                forCellWithReuseIdentifier: TabCollectionViewCell.identifier
            )
            let layout = newValue.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.estimatedItemSize = TabCollectionViewCell.estimatedSize
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    func configureTitles(titles: [String]) {
        self.titles = titles
    }

    func setupUnderlineIfNeeded() {
        guard underlineView == nil else {
            return
        }
        guard let firstCell = tabCollectionView.cellForItem(at: [0, 0]) as? TabCollectionViewCell else {
            return
        }

        underlineView = UIView(
            frame: .init(
                x: firstCell.frame.origin.x,
                y: firstCell.underlineOffsetY,
                width: firstCell.frame.width,
                height: Self.underlineHeight
            )
        )
        underlineView?.backgroundColor = underlineColor
        tabCollectionView.addSubview(underlineView!)
    }

    func titleOfTab(at index: Int) -> String {
        titles[index]
    }

    func scrollToItem(toIndexPath indexPath: IndexPath) {
        self.tabCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        self.moveUnderline(to: indexPath)
    }
}

extension TabView {
    /// xibからカスタムViewをロード
    private func configureView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        addSubview(view)
    }

    /// 指定indexpathのセルの下にアンダーラインを移動させる
    private func moveUnderline(to indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25) {
            if let cell = self.tabCollectionView.cellForItem(at: indexPath) {
                self.underlineView?.frame.size.width = cell.frame.width
                self.underlineView?.frame.origin.x = cell.frame.origin.x
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TabView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return titles.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let tabCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TabCollectionViewCell.identifier,
            for: indexPath
        ) as! TabCollectionViewCell
        tabCell.title = titles[indexPath.row]
        return tabCell
    }
}

// MARK: - UICollectionViewDelegate
extension TabView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.tabView(self, didSelectTabAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TabView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
