//
//  Color+Hex.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import UIKit

extension UIColor {
    class func color(from hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: hexSanitized)
        var rgb: UInt64 = 0
        
        guard scanner.scanHexInt64(&rgb) else {
            return nil
        }
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hexSanitized.count == 6 {
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
        } else if hexSanitized.count == 8 {
            red = CGFloat((rgb >> 24) & 0xFF) / 255.0
            green = CGFloat((rgb >> 16) & 0xFF) / 255.0
            blue = CGFloat((rgb >> 8) & 0xFF) / 255.0
            alpha = CGFloat(rgb & 0xFF) / 255.0
        } else {
            return nil
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let hexRed = String(format: "%02X", Int(red * 255))
        let hexGreen = String(format: "%02X", Int(green * 255))
        let hexBlue = String(format: "%02X", Int(blue * 255))
        let hexAlpha = String(format: "%02X", Int(alpha * 255))
        return "#\(hexRed)\(hexGreen)\(hexBlue)\(hexAlpha)"
    }
}
