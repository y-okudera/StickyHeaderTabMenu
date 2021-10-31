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

            /**
             *  Re-size (Shrink) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be greater than the previous offset indicating an upward scroll.
             *  2. The top view's height should be within its minimum height.
             *  3. Optional - Collapse the header view only when the table view's edge is below the above view - This case will occur if you are using Step 2 of the next condition and have a refresh control in the table view.
             */

            if delta > 0,
                topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y > 0 {

                dragDirection = .up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }

            /**
             *  Re-size (Expand) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be lesser than the previous offset indicating an downward scroll.
             *  2. Optional - The top view's height should be within its maximum height. Skipping this step will give a bouncy effect. Note that you need to write extra code in the outer view controller to bring back the view to the maximum possible height.
             *  3. Expand the header view only when the table view's edge is below the header view, else the table view should first scroll till it's offset is 0 and only then the header should expand.
             */

            if delta < 0,
                // topViewUnwrappedHeight < topViewHeightConstraintRange.upperBound,
                scrollView.contentOffset.y < 0 {

                dragDirection = .down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }

        oldContentOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        //You should not bring the view down until the table view has scrolled down to it's top most cell.

        if scrollView.contentOffset.y <= 0 {

            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        //You should not bring the view down until the table view has scrolled down to it's top most cell.

        if decelerate == false && scrollView.contentOffset.y <= 0 {

            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}
