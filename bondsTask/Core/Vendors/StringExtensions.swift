//
//  StringExtention.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 28/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
