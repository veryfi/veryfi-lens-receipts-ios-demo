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
    let imageProcessingSection: [(Keys,Types)]  = [(.autoRotateIsOn, .switchCell),(.autoDocDetectionAndCropIsOn,.switchCell),(.blurDetectionIsOn, .switchCell),(.autoSkewCorrectionIsOn,.switchCell),(.autoCropGalleryIsOn, .switchCell)]
    let uiSection: [(Keys,Types)]  = [(.docDetectFillUIColor, .colorCell), (.submitButtonBackgroundColor, .stringColorCell),(.submitButtonBorderColor,.stringColorCell),(.submitButtonFontColor,.stringColorCell),(.docDetectStrokeUIColor,.colorCell),(.submitButtonCornerRadius, .integerValueCell),(.manualCropIsOn,.switchCell),(.moreMenuIsOn,.switchCell),(.moreSettingsMenuIsOn,.switchCell),(.galleryIsOn,.switchCell),(.dictateIsOn,.switchCell),(.emailCCIsOn,.switchCell),(.emailCCDomain,.stringValueCell),(.rotateDocIsOn,.switchCell),(.shieldProtectionIsOn,.switchCell)]
    let apiSection: [(Keys,Types)]  = [(.autoDeleteAfterProcessing, .switchCell),(.boostModeIsOn, .switchCell),(.boundingBoxesIsOn, .switchCell),(.detectBlurResponseIsOn,.switchCell),(.isProduction,.switchCell),(.confidenceDetailsIsOn,.switchCell),(.parseAddressIsOn,.switchCell),(.externalId,.stringValueCell)]
    lazy var sections: [[(Keys,Types)]] = [generalSection, imageProcessingSection, uiSection, apiSection]
    
    // MARK: Data
    var jsonSettings: [String : Any] = [:]
    var changingColor: (Keys, Types)? = nil
    var changingColorIndexPath: IndexPath?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(cameraPressed))
        let settings = VeryfiLensSettings()
        jsonSettings = settings.json
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? LogsViewController {
            viewController.jsonSettings = self.jsonSettings
        }
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
            let newValue = alertController.textFields?[0].text?.replacingOccurrences(of: ",", with: ".")
            self.setSettingValueType(key: title, value: newValue, type: type)
            self.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
        
    //MARK: Selectors
    
    @objc func settingSwitchChanged(sender: VeryfiSwitch) {
        guard let key = sender.key, let indexPath = sender.indexPath else { return }
        let value = sender.isOn
        jsonSettings[key] = value
        settingsTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func cameraPressed() {
        performSegue(withIdentifier: "showLensConsole", sender: self)
    }
    
    //MARK: Private
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
}
