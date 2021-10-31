//
//  Page.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import Foundation
import UIKit

struct Page {
    var name: String
    var contentViewController: UIViewController

    init(name: String, contentViewController: UIViewController) {
        self.name = name
        self.contentViewController = contentViewController
    }
}

struct PageCollection {
    var selectedPageIndex = 0
    var pages = [Page]()
}
