//
//  BarAppearance.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/31.
//

import UIKit

protocol BarAppearance where Self: UIViewController {
    func setupStatusBar(backgroundColor: UIColor)
    func setupNavigationBar(title: String, backgroundColor: UIColor)
}

// MARK: - Default args

extension BarAppearance {
    func setupStatusBar() {
        self.setupStatusBar(backgroundColor: .systemBackground)
    }

    func setupNavigationBar(title: String) {
        self.setupNavigationBar(title: title, backgroundColor: .systemBackground)
    }
}

// MARK: - Impl

extension BarAppearance {
    func setupStatusBar(backgroundColor: UIColor) {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

            let statusbarView = UIView()
            statusbarView.backgroundColor = backgroundColor
            view.addSubview(statusbarView)

            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true

        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = backgroundColor
        }
    }

    func setupNavigationBar(title: String, backgroundColor: UIColor) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.backgroundColor = backgroundColor
    }
}

