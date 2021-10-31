//
//  ContentViewController.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

class ContentViewController: UIViewController {

    static func make(topViewHeightConstraintRange: Range<CGFloat>!, numberOfCells: Int, tabTitle: String) -> Self {
        let identifier = "ContentViewController"
        let sb = UIStoryboard(name: identifier, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: identifier) as! Self
        vc.topViewHeightConstraintRange = topViewHeightConstraintRange
        vc.numberOfCells = numberOfCells
        vc.tabTitle = tabTitle
        return vc
    }

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.register(
                UINib(nibName: TopTableViewCell.identifier, bundle: nil),
                forCellReuseIdentifier: TopTableViewCell.identifier
            )
        }
    }

    // MARK: - Properties

    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    private var topViewHeightConstraintRange: Range<CGFloat>!
    private var dragDirection: DragDirection = .up
    private var oldContentOffset: CGPoint = .zero

    /// Debug data
    private var numberOfCells: Int = 0
    private var tabTitle: String = ""

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("ContentViewController", #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension ContentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopTableViewCell.identifier, for: indexPath) as! TopTableViewCell
        cell.title = "[\(tabTitle)] cell \(indexPath.row + 1)"

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContentViewController: UITableViewDelegate {

}

// MARK: - UIScrollViewDelegate
extension ContentViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let delta = scrollView.contentOffset.y - oldContentOffset.y

        let topViewCurrentHeightConst = innerTableViewScrollDelegate?.currentHeaderHeight

        if let topViewUnwrappedHeight = topViewCurrentHeightConst {

            if delta > 0,
                topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y > 0 {

                // Re-size (Shrink) the top view.
                dragDirection = .up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }

            if delta < 0,
                scrollView.contentOffset.y < 0 {

                // Re-size (Expand) the top view.
                dragDirection = .down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }

        oldContentOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}
