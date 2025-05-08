//
//  RSSReaderUITests.swift
//  RSSReaderUITests
//
//  Created by Martino Mamić on 12.04.25.
//

import XCTest
import Common

final class RSSReaderUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testBasicNavigation() throws {
            let feedsTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.feedsTab).firstMatch
            let favoritesTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.favoritesTab).firstMatch
            let exploreTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.exploreTab).firstMatch
            
            XCTAssertTrue(feedsTab.exists || app.tabBars.buttons["Feeds"].exists, "Feeds tab doesn't exist")
            XCTAssertTrue(favoritesTab.exists || app.tabBars.buttons["Favorites"].exists, "Favorites tab doesn't exist")
            XCTAssertTrue(exploreTab.exists || app.tabBars.buttons["Explore"].exists, "Explore tab doesn't exist")
            
            if favoritesTab.exists {
                favoritesTab.tap()
            } else {
                app.tabBars.buttons["Favorites"].tap()
            }
            XCTAssertTrue(app.navigationBars["Favorite Feeds"].exists, "Favorite Feeds navigation bar not found")
            
            if exploreTab.exists {
                exploreTab.tap()
            } else {
                app.tabBars.buttons["Explore"].tap()
            }
            XCTAssertTrue(app.navigationBars["Explore Feeds"].exists, "Explore Feeds navigation bar not found")
            
            if feedsTab.exists {
                feedsTab.tap()
            } else {
                app.tabBars.buttons["Feeds"].tap()
            }
            XCTAssertTrue(app.navigationBars["RSS Feeds"].exists, "RSS Feeds navigation bar not found")
        }
}
