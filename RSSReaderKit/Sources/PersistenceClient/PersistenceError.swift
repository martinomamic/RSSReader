//
//  PersistenceError.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 17.04.25.
//

public enum PersistenceError: Error, Equatable {
    case saveFailed(String)
    case loadFailed(String)
}
