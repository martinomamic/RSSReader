//
//  RSSElement.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 13.04.25.
//

import Foundation

public enum RSSElement: String {
    case item
    case image
    case title
    case description
    case link
    case pubDate
    case url
    case enclosure
    case channel
}

public enum RSSAttribute: String {
    case url
    case type
    case length
}

public enum MediaType: String {
    case image = "image/"

    public func matches(_ value: String) -> Bool {
        return value.hasPrefix(self.rawValue)
    }
}

public enum DateFormat: String {
    case rfc822 = "EEE, dd MMM yyyy HH:mm:ss Z"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"

    public static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for format in [DateFormat.rfc822, DateFormat.iso8601] {
            formatter.dateFormat = format.rawValue
            guard let date = formatter.date(from: dateString) else {
                return nil
            }
            return date
        }

        return nil
    }
}
