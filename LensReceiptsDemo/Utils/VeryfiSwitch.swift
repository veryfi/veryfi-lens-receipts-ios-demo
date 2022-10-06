//
//  VeryfiSwitch.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import UIKit

class VeryfiSwitch: UISwitch {
    var key: String?
    var indexPath: IndexPath?
    convenience init(key: String, indexPath: IndexPath) {
        self.init()
        self.key = key
        self.indexPath = indexPath
    }
}
