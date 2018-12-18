//
//  UITableView+Animator.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//
import Foundation
import UIKit

extension UITableView {
    
    /// Gets the currently visibleCells of a section.
    ///
    /// - Parameter section: The section to filter the cells.
    /// - Returns: Array of visible UITableViewCell in the argument section.
    func visibleCells(in section: Int) -> [UITableViewCell] {
        return visibleCells.filter { indexPath(for: $0)?.section == section }
    }
}
