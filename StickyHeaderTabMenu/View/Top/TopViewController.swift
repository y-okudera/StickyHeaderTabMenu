//
//  TopViewController.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

final class TopViewController: UIViewController, BarAppearance {

    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(
                UINib(nibName: TopTableViewCell.identifier, bundle: nil),
                forCellReuseIdentifier: TopTableViewCell.identifier
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatusBar()
        setupNavigationBar(title: "Top")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
}

extension TopViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopTableViewCell.identifier, for: indexPath) as! TopTableViewCell
        switch indexPath.row {
        case 0:
            cell.title = "StickyHeaderTabMenu-Navigation"
        case 1:
            cell.title = "StickyHeaderTabMenu-Modal"
        default:
            break
        }
        return cell
    }
}

extension TopViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = StickyHeaderViewController.make(transitionType: .navigation)
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = StickyHeaderViewController.make(transitionType: .modal)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        default:
            break
        }
    }
}
