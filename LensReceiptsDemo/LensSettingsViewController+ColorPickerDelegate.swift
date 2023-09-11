//
//  LensSettingsViewController+ColorPickerDelegate.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import UIKit

extension LensSettingsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if let changingColor = changingColor, let indexPath = changingColorIndexPath {
            if changingColor.1 == .stringColorCell {
                jsonSettings[changingColor.0.rawValue] = viewController.selectedColor.toHexString()
            }
            settingsTableView.reloadRows(at: [indexPath], with: .automatic)
            self.changingColor = nil
            changingColorIndexPath = nil
        }
    }
}
