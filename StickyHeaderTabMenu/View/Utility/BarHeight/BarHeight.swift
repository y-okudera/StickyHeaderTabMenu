//
//  BarHeight.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/31.
//

import UIKit

protocol BarHeight where Self: UIViewController {
    func statusBarHeight() -> CGFloat
    func navigationBarHeight() -> CGFloat
}

extension BarHeight {
    func statusBarHeight() -> CGFloat {
        self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
    }

    func navigationBarHeight() -> CGFloat {
        self.navigationController?.navigationBar.frame.height ?? .zero
    }
}
