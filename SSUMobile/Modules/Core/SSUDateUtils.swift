//
//  SSUDateUtils.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/16/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUDateUtils {
    private static var iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter
    }()
    
    static func dateFrom(iso8601String: String) -> Date? {
        return iso8601Formatter.date(from: iso8601String)
    }
    
    static func iso8601String(from date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
}
