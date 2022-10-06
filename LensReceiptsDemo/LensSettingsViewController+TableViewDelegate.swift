//
//  LensSettingsViewController+TableViewDelegate.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import UIKit

extension LensSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sections[indexPath.section][indexPath.row].1
        if type == .stringValueCell || type == .doubleValueCell || type == .integerValueCell {
            handleValueCellTap(indexPath: indexPath)
        } else if type == .colorCell || type == .stringColorCell {
            handleColorCellTap(indexPath: indexPath)
        }
    }
}
