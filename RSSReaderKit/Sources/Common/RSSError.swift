//
//  RSSError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

public enum RSSError: Error {
    case invalidURL
    case networkError(Error)
    case parsingError(Error)
    case unknown
}
