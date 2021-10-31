//
//  InnerTableViewScrollDelegate.swift
//  StickyHeaderTabMenu
//
//  Created by Yuki Okudera on 2021/10/29.
//

import UIKit

protocol InnerTableViewScrollDelegate: AnyObject {
    var currentHeaderHeight: CGFloat { get }
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}
