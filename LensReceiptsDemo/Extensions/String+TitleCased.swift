//
//  String+TitleCased.swift
//  LensReceiptsDemo
//
//  Created by Sebastian Giraldo on 6/10/22.
//

import Foundation

extension String {
    func titlecased() -> String {
        let preProcessed = self.replacingOccurrences(of: "IsOn", with: "")
            .replacingOccurrences(of: "PDF", with: "Pdf")
            .replacingOccurrences(of: "MB", with: "Mb")
            .replacingOccurrences(of: "UI", with: "")
            .replacingOccurrences(of: "CC", with: "Cc")
        return preProcessed.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: preProcessed.range(of: preProcessed))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
