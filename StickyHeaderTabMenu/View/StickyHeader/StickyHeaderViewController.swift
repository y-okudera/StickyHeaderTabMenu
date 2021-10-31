//
//  StickyHeaderViewController.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

final class StickyHeaderViewController: UIViewController, BarAppearance, BarHeight {

    static func make(transitionType: TransitionType) -> Self {
        let identifier = "StickyHeaderViewController"
        let sb = UIStoryboard(name: identifier, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: identifier) as! Self
        vc.transitionType = transitionType
        return vc
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerView: UIView!

    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView! {
        willSet {
            newValue.isHidden = true
        }
    }
    @IBOutlet private weak var tabView: TabView! {
        willSet {
            newValue.delegate = self
        }
    }

    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties

    private var headerImageVisualEffectView: UIVisualEffectView?
    private var topViewInitialHeight: CGFloat = 138
    private lazy var topViewFinalHeight: CGFloat = {
        switch transitionType {
        case .modal:
            return statusBarHeight() + navigationBarHeight() + tabView.frame.height
        case .navigation:
            return .zero
        }
    }()
    private lazy var topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

    private var pageViewController = UIPageViewController()
    private var pageCollection = PageCollection()

    private var transitionType = TransitionType.modal

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAppearance()
        setupCloseButton()
        tabView.configureTitles(titles: [
            "すべて",
            "ファンタジー",
            "恋愛",
            "アクション",
            "ドラマ",
            "ホラー・ミステリー",
            "スポーツ",
            "裏社会・アングラ",
            "グルメ",
            "日常",
        ])
        setupPagingViewController()
        populateBottomView()
        addPanGestureToHeaderView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabView.setupUnderlineIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ヘッダビューの基準の位置を更新
        switch transitionType {
        case .modal:
            headerViewTopConstraint.constant = 0
        case .navigation:
            headerViewTopConstraint.constant = statusBarHeight() + navigationBarHeight()
        }

        debugPrint("statusBarHeight", statusBarHeight(), "navigationBarHeight", navigationBarHeight())
    }

    // MARK: View Setup

    func setupNavigationAppearance() {
        switch transitionType {
        case .modal:
            break
        case .navigation:
            setupStatusBar()
            setupNavigationBar(title: "StickyHeader")
        }
    }

    func setupCloseButton() {
        switch transitionType {
        case .modal:
            closeButton.isHidden = false
        case .navigation:
            closeButton.isHidden = true
        }
    }

    func setupPagingViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }

    func populateBottomView() {

        for index in 0..<tabView.numberOfTabs {

            let tabContentVC = ContentViewController.make(
                topViewHeightConstraintRange: topViewHeightConstraintRange,
                numberOfCells: 30,
                tabTitle: tabView.titleOfTab(at: index)
            )
            tabContentVC.innerTableViewScrollDelegate = self

            let displayName = tabView.titleOfTab(at: index)
            let page = Page(name: displayName, contentViewController: tabContentVC)
            pageCollection.pages.append(page)
        }

        let initialPage = 0

        pageViewController.setViewControllers(
            [pageCollection.pages[initialPage].contentViewController],
            direction: .forward,
            animated: true,
            completion: nil
        )


        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        containerView.addSubview(pageViewController.view)

        pinPagingViewControllerToContainerView()
    }

    func pinPagingViewControllerToContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

    func addPanGestureToHeaderView() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(headerViewMoved))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(topViewPanGesture)
    }

    // MARK: - Action Methods

    @IBAction func tappedCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

    private var dragInitialY: CGFloat = 0
    private var dragPreviousY: CGFloat = 0
    private var dragDirection: DragDirection = .up
    @objc func headerViewMoved(_ gesture: UIPanGestureRecognizer) {

        var dragYDiff: CGFloat

        switch gesture.state {
        case .began:
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
        case .changed:
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .down : .up
            innerTableViewDidScroll(withDistance: dragYDiff)
        case .ended:
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
        default:
            return
        }
    }
}

// MARK: - TabViewDelegate
extension StickyHeaderViewController: TabViewDelegate {
    func tabView(_ tabView: TabView, didSelectTabAt indexPath: IndexPath) {
        if indexPath.item == pageCollection.selectedPageIndex {
            return
        }

        var direction: UIPageViewController.NavigationDirection

        if indexPath.item > pageCollection.selectedPageIndex {
            direction = .forward
        } else {
            direction = .reverse
        }

        pageCollection.selectedPageIndex = indexPath.item

        tabView.scrollToItem(toIndexPath: indexPath)

        setPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }

    private func setPagingView(
        toPageWithAtIndex index: Int,
        andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection
    ) {
        pageViewController.setViewControllers(
            [pageCollection.pages[index].contentViewController],
            direction: navigationDirection,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - UIPageViewControllerDataSource
extension StickyHeaderViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {

        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.contentViewController == viewController }) {
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                // go to previous page in array
                return pageCollection.pages[currentViewControllerIndex - 1].contentViewController
            }
        }
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {

        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.contentViewController == viewController }) {
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                // go to next page in array
                return pageCollection.pages[currentViewControllerIndex + 1].contentViewController
            }
        }
        return nil
    }
}

//MARK: - UIPageViewControllerDelegate
extension StickyHeaderViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {

        guard completed else { return }

        guard let currentVC = pageViewController.viewControllers?.first else { return }

        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.contentViewController == currentVC }) else { return }

        // Scroll tab
        let ip = IndexPath(item: currentVCIndex, section: 0)
        tabView.scrollToItem(toIndexPath: ip)
    }
}

// Sticky Header Effect
// MARK: - InnerTableViewScrollDelegate
extension StickyHeaderViewController: InnerTableViewScrollDelegate {

    var currentHeaderHeight: CGFloat {
        return headerViewHeightConstraint.constant
    }

    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        headerViewHeightConstraint.constant -= scrollDistance

        // ヘッダービューの最大の高さを指定
        if headerViewHeightConstraint.constant > topViewInitialHeight * 1.5 {
            headerViewHeightConstraint.constant = topViewInitialHeight * 1.5

            // 最大の高さに到達したら、ブラー効果を付与する
            addBlurEffectToHeaderImageView()

            // 最大の高さに到達したら、リフレッシュ処理する
            refreshView()
        }

        // ヘッダービューの最小の高さを指定
        if headerViewHeightConstraint.constant <= topViewFinalHeight {
            headerViewHeightConstraint.constant = topViewFinalHeight
            // 最小の高さに到達したら、ブラー効果を付与する
            addBlurEffectToHeaderImageView()
        }
    }

    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        // スクロール停止時にローディング中でない且つヘッダービューが最小の高さでなければ、ブラー効果を外す
        if activityIndicatorView.isAnimating || headerViewHeightConstraint.constant <= topViewFinalHeight {
            addBlurEffectToHeaderImageView()
        } else {
            removeBlurEffectFromHeaderImageView()
        }

        if headerViewHeightConstraint.constant <= topViewFinalHeight + 20 {
            scrollToFinalView()
        } else if headerViewHeightConstraint.constant <= topViewInitialHeight - 20 {
            switch scrollDirection {
            case .down:
                scrollToInitialView()
            case .up:
                scrollToFinalView()
            }
        } else {
            scrollToInitialView()
        }
    }

    func scrollToInitialView() {

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - topViewInitialHeight)

        var time = distanceToBeMoved / 500

        if time < 0.25 {
            time = 0.25
        }

        headerViewHeightConstraint.constant = topViewInitialHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }

    func scrollToFinalView() {

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - topViewFinalHeight)

        var time = distanceToBeMoved / 500

        if time < 0.25 {
            time = 0.25
        }

        headerViewHeightConstraint.constant = topViewFinalHeight
        addBlurEffectToHeaderImageView()

        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension StickyHeaderViewController {

    private func refreshView() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) {
            self.activityIndicatorView.isHidden = false
        } completion: { _ in
            if !self.activityIndicatorView.isAnimating {
                self.activityIndicatorView.startAnimating()
            }
        }

        // For debug
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if self?.activityIndicatorView.isAnimating == true {
                self?.activityIndicatorView.stopAnimating()
            }
            self?.removeBlurEffectFromHeaderImageView()
            self?.activityIndicatorView.isHidden = true
        }
    }

    func addBlurEffectToHeaderImageView() {
        guard self.headerImageVisualEffectView == nil else {
            return
        }
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.headerImageView.bounds

        // for supporting device rotation
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.headerImageVisualEffectView = blurEffectView
        self.headerImageView.addSubview(blurEffectView)
    }

    func removeBlurEffectFromHeaderImageView() {
        for subview in self.headerImageView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        self.headerImageVisualEffectView = nil
    }
}
