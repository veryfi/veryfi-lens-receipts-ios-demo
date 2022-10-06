//
//  LensSettingsViewController.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 5/10/22.
//

import UIKit
import VeryfiLens

class LensSettingsViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var settingsTableView: UITableView!
    
    // MARK: Sections Data
    let sectionTitles = [
        "General Settings",
        "Image Processing Settings",
        "UI Settings",
        "API Settings"
    ]
    let generalSection: [(Keys,Types)] = [(.autoLightDetectionIsOn, .switchCell), (.stitchIsOn, .switchCell), (.allowSubmitUndetectedDocsIsOn, .switchCell), (.autoSubmitDocumentOnCapture, .switchCell), (.backupDocsToGallery, .switchCell), (.returnStitchedPDF, .switchCell), (.closeCameraOnSubmit, .switchCell), (.locationServicesIsOn, .switchCell), (.originalImageMaxSizeInMB, .doubleValueCell)]
    let imageProcessingSection: [(Keys,Types)]  = [(.autoRotateIsOn, .switchCell)]
    let uiSection: [(Keys,Types)]  = [(.docDetectFillUIColor, .colorCell), (.submitButtonBackgroundColor, .stringColorCell)]
    let apiSection: [(Keys,Types)]  = [(.autoDeleteAfterProcessing, .switchCell)]
    lazy var sections: [[(Keys,Types)]] = [generalSection, imageProcessingSection, uiSection, apiSection]
    
    // MARK: Data
    var jsonSettings: [String : Any] = [:]
    var changingColor: (Keys, Types)? = nil
    var changingColorIndexPath: IndexPath?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = VeryfiLensSettings()
        jsonSettings = settings.json
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.reloadData()
    }
    
    //MARK: Cell values handlers
    func handleColorCellTap(indexPath: IndexPath) {
        let title = sections[indexPath.section][indexPath.row].0.rawValue
        let type = sections[indexPath.section][indexPath.row].1
        let rawColor = type == .colorCell ? jsonSettings[title] as? UIColor ?? UIColor.green.withAlphaComponent(0.3) : UIColor.color(from: jsonSettings[title] as? String ?? "")
        guard let color = rawColor else { return }
        
        changingColor = sections[indexPath.section][indexPath.row]
        changingColorIndexPath = indexPath
        
        let picker = UIColorPickerViewController()
        picker.selectedColor = color
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func handleValueCellTap(indexPath: IndexPath) {
        let type = sections[indexPath.section][indexPath.row].1
        let title = sections[indexPath.section][indexPath.row].0.rawValue
        var value = ""
        var keyboardType: UIKeyboardType = .default
        if type == .stringValueCell {
            value = jsonSettings[title] as? String ?? ""
        } else if type == .doubleValueCell {
            value = String(jsonSettings[title] as? Double ?? 0.0)
            keyboardType = .decimalPad
        } else if type == .integerValueCell {
            value = String(jsonSettings[title] as? Int ?? 0)
            keyboardType = .numberPad
        }
        
        let alertController = UIAlertController(title: title.titlecased(), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = value
            textField.keyboardType = keyboardType
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let newValue = alertController.textFields?[0]
            self.setSettingValueType(key: title, value: newValue?.text, type: type)
            self.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    private func setSettingValueType (key: String, value: String?, type: Types) {
        guard let value = value else { return }
        if type == .stringValueCell {
            jsonSettings[key] = value
        } else if type == .doubleValueCell, let newValue = Double(value) {
            jsonSettings[key] = newValue
        } else if type == .integerValueCell, let newValue = Int(value) {
            jsonSettings[key] = newValue
        }
    }
    
    @objc func settingSwitchChanged(sender: VeryfiSwitch) {
        guard let key = sender.key, let indexPath = sender.indexPath else { return }
        let value = sender.isOn
        jsonSettings[key] = value
        settingsTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension LensSettingsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if let changingColor = changingColor, let indexPath = changingColorIndexPath {
            if changingColor.1 == .colorCell {
                jsonSettings[changingColor.0.rawValue] = viewController.selectedColor
            } else if changingColor.1 == .stringColorCell {
                jsonSettings[changingColor.0.rawValue] = viewController.selectedColor.toHexString()
            }
            settingsTableView.reloadRows(at: [indexPath], with: .automatic)
            self.changingColor = nil
            changingColorIndexPath = nil
        }
    }
}

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

extension LensSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = sections[indexPath.section][indexPath.row].0.rawValue
        let type = sections[indexPath.section][indexPath.row].1
        
        switch type {
        case .switchCell:
            let isOn = jsonSettings[title] as? Bool ?? false
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as? SwitchTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingSwitch.isOn = isOn
            cell?.settingSwitch.key = title
            cell?.settingSwitch.indexPath = indexPath
            cell?.settingSwitch.addTarget(self, action: #selector(settingSwitchChanged), for: .valueChanged)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .doubleValueCell:
            let value = jsonSettings[title] as? Double ?? 0.0
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell") as? ValueTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingLabel.text = String(value)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .integerValueCell:
            let value = jsonSettings[title] as? Int ?? 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell") as? ValueTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingLabel.text = String(value)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .stringValueCell:
            let value = jsonSettings[title] as? String ?? ""
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell") as? ValueTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingLabel.text = value
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .colorCell:
            let color = jsonSettings[title] as? UIColor
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell") as? ColorTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingView.backgroundColor = color ?? UIColor.green.withAlphaComponent(0.3)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        case .stringColorCell:
            let rawColor = jsonSettings[title] as? String ?? ""
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell") as? ColorTableViewCell
            cell?.titleLabel.text = title.titlecased()
            cell?.settingView.backgroundColor = UIColor.color(from: rawColor)
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}
