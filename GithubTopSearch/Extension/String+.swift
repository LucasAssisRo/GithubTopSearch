//
//  String+.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 11.12.21.
//

import Foundation

extension String {
    var localized: String { NSLocalizedString(self, comment: "") }
    
    func localized(arg1: CVarArg, arg2: CVarArg) -> String {
        String.localizedStringWithFormat(localized, arg1, arg2)
    }

    static func countSensitiveLocalized(singularString: String, pluralString: String, count: Int) -> String {
        count == 1
            ? String.localizedStringWithFormat(singularString.localized, count)
            : String.localizedStringWithFormat(pluralString.localized, count)
    }
}
