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
    
    func testAddFeedWorkflow() throws {
            let feedsTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.feedsTab).firstMatch
            if feedsTab.exists {
                feedsTab.tap()
            } else {
                app.tabBars.buttons["Feeds"].tap()
            }
            
            // Verify we're on the Feeds tab
            XCTAssertTrue(app.navigationBars["RSS Feeds"].exists, "Not on RSS Feeds screen")
            
            // Find Add Feed button using multiple approaches
            let addButtonById = app.buttons.matching(identifier: AccessibilityIdentifier.FeedList.addFeedButton).firstMatch
            let addButtonByLabel = app.buttons["Add Feed"]
            
            // Tap the Add Feed button
            if addButtonById.exists {
                addButtonById.tap()
            } else if addButtonByLabel.exists {
                addButtonByLabel.tap()
            } else {
                let navBarAddButton = app.navigationBars.buttons.element(boundBy: 0)
                navBarAddButton.tap()
            }
            
            let addFeedNavBar = app.navigationBars["Add Feed"]
            let navBarExpectation = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == true"),
                object: addFeedNavBar
            )
            wait(for: [navBarExpectation], timeout: 5.0)
            XCTAssertTrue(addFeedNavBar.exists, "Add Feed navigation bar not found")

            let addFeedScreenshot = XCTAttachment(screenshot: app.screenshot())
            addFeedScreenshot.name = "Add Feed Screen"
            addFeedScreenshot.lifetime = .keepAlways
            add(addFeedScreenshot)
            
            let bbcButtonById = app.buttons.matching(identifier: AccessibilityIdentifier.AddFeed.bbcExampleButton).firstMatch
            let bbcButtonByLabel = app.buttons["BBC News"]
            
            if bbcButtonById.exists {
                bbcButtonById.tap()
            } else if bbcButtonByLabel.exists {
                bbcButtonByLabel.tap()
            } else {
                XCTFail("BBC example button not found")
            }
            
            let urlFieldById = app.textFields.matching(identifier: AccessibilityIdentifier.AddFeed.urlTextField).firstMatch
            let urlFieldByPlaceholder = app.textFields["Feed URL"]
            
            XCTAssertTrue(urlFieldById.exists || urlFieldByPlaceholder.exists, "URL text field not found")
            
            let confirmButtonById = app.buttons.matching(identifier: AccessibilityIdentifier.AddFeed.addButton).firstMatch
            let confirmButtonByLabel = app.buttons["Add"]
            
            if confirmButtonById.exists {
                confirmButtonById.tap()
            } else if confirmButtonByLabel.exists {
                confirmButtonByLabel.tap()
            } else {
                let navBarConfirmButton = app.navigationBars.buttons.element(boundBy: 1)
                navBarConfirmButton.tap()
            }
            
            let rssFeedsNavBar = app.navigationBars["RSS Feeds"]
            let rssFeedsExpectation = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == true"),
                object: rssFeedsNavBar
            )
            wait(for: [rssFeedsExpectation], timeout: 15.0)
            
            XCTAssertTrue(rssFeedsNavBar.exists, "Did not return to RSS Feeds screen")
            
            let afterAddScreenshot = XCTAttachment(screenshot: app.screenshot())
            afterAddScreenshot.name = "After Adding Feed"
            afterAddScreenshot.lifetime = .keepAlways
            add(afterAddScreenshot)
        }
}
