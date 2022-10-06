//
//  LensSettings+TableViewDataSource.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import UIKit

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
