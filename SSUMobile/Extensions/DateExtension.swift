//
//  DateExtension.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/16/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

extension Date {
    var iso8601String: String {
        return SSUDateUtils.iso8601String(from: self)
    }
}
