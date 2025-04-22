//
//  ErrorConversionTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 22.04.25.
//

import Testing
import Common
import RSSClient
import NotificationClient
import ExploreClient
import PersistenceClient
import Foundation

@Suite struct ErrorConversionTests {
    @Test("RSSError conversions")
    func testRSSErrorConversion() {
        let invalidURLError = RSSError.invalidURL
        let convertedError = invalidURLError.asAppError()
        #expect(convertedError == AppError.invalidURL)
        
        let networkError = RSSError.networkError(NSError(domain: "test", code: -1))
        let convertedNetworkError = networkError.asAppError()
        #expect(convertedNetworkError == AppError.networkError)
    }
    
    @Test("ExploreError conversions")
    func testExploreErrorConversion() {
        let invalidURLError = ExploreError.invalidURL
        let convertedError = invalidURLError.asAppError()
        #expect(convertedError == AppError.invalidURL)
        
        let decodingError = ExploreError.decodingFailed("Invalid format")
        let convertedDecodingError = decodingError.asAppError()
        #expect(convertedDecodingError == AppError.parsingError)
    }
    
    @Test("NotificationError conversions")
    func testNotificationErrorConversion() {
        let permissionError = NotificationError.permissionDenied
        let convertedError = permissionError.asAppError()
        #expect(convertedError == AppError.permissionDenied)
    }
    
    @Test("PersistenceError conversions")
    func testPersistenceErrorConversion() {
        let saveError = PersistenceError.saveFailed("Save failed")
        let convertedError = saveError.asAppError()
        #expect(convertedError == AppError.unknown("Failed to save data"))
        
        let loadError = PersistenceError.loadFailed("Load failed")
        let convertedLoadError = loadError.asAppError()
        #expect(convertedLoadError == AppError.unknown("Failed to load data"))
    }
    
    @Test("General error utility function")
    func testErrorUtilsFunction() {
        let originalAppError = AppError.networkError
        let convertedAppError = ErrorUtils.toAppError(originalAppError)
        #expect(convertedAppError == originalAppError)
        
        let domainError = RSSError.invalidURL
        let convertedDomainError = ErrorUtils.toAppError(domainError)
        #expect(convertedDomainError == AppError.invalidURL)

        let unknownError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let convertedUnknownError = ErrorUtils.toAppError(unknownError)
        if case let .unknown(message) = convertedUnknownError {
            #expect(message == "Test error")
        } else {
            #expect(Bool(false), "Should be .unknown error type")
        }
    }
}
