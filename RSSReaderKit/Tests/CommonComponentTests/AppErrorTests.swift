//
//  AppErrorTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import Foundation

@testable import Common

@Suite struct AppErrorTests {
    @Test("AppError has correct error descriptions")
    func testErrorDescriptions() {
        #expect(AppError.invalidURL.errorDescription == "Please enter a valid URL")
        #expect(AppError.networkError.errorDescription == "Unable to connect to server. Please check your internet connection and try again.")
        #expect(AppError.parsingError.errorDescription == "Unable to read feed content. The feed format may be unsupported.")
        #expect(AppError.duplicateFeed.errorDescription == "This feed is already in your list")
        #expect(AppError.feedNotFound.errorDescription == "Feed not found")
        #expect(AppError.permissionDenied.errorDescription == "Notifications permission denied. Please enable notifications in Settings.")
        #expect(AppError.general.errorDescription == "Something went wrong. Please try again.")
        
        let customMessage = "Custom error message"
        #expect(AppError.unknown(customMessage).errorDescription == customMessage)
    }
    
    @Test("AppError equality works correctly")
    func testEquality() {
        #expect(AppError.invalidURL == AppError.invalidURL)
        #expect(AppError.networkError == AppError.networkError)
        #expect(AppError.invalidURL != AppError.networkError)
        
        #expect(AppError.unknown("Custom message") == AppError.unknown("Custom message"))
        #expect(AppError.unknown("Message 1") != AppError.unknown("Message 2"))
    }
    
    @Test("AppError id is based on description")
    func testErrorID() {
        #expect(AppError.invalidURL.id == AppError.invalidURL.errorDescription)
        #expect(AppError.networkError.id == AppError.networkError.errorDescription)
        
        let customMessage = "Custom error message"
        #expect(AppError.unknown(customMessage).id == customMessage)
    }
    
    @Test("ErrorUtils converts various errors to AppError")
    func testErrorUtilsToAppError() {
        let appError = AppError.invalidURL
        #expect(ErrorUtils.toAppError(appError) == appError)
        
        let mockConvertibleError = MockAppErrorConvertible()
        #expect(ErrorUtils.toAppError(mockConvertibleError) == AppError.parsingError)
        
        let genericError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Generic error"])
        let convertedGenericError = ErrorUtils.toAppError(genericError)
        if case let .unknown(message) = convertedGenericError {
            #expect(message == "Generic error")
        } else {
            #expect(Bool(false), "Should convert to unknown error type")
        }
    }
}

struct MockAppErrorConvertible: Error, AppErrorConvertible {
    func asAppError() -> AppError {
        return .parsingError
    }
}
