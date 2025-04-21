//
//  RSSReaderUITestsLaunchTests.swift
//  RSSReaderUITests
//
//  Created by Martino Mamić on 12.04.25.
//

import XCTest
import Common

final class RSSReaderUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
        func testLaunch() throws {
            let app = XCUIApplication()
            app.launch()

            let feedsTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.feedsTab).firstMatch
            let favoritesTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.favoritesTab).firstMatch
            let exploreTab = app.tabBars.buttons.matching(identifier: AccessibilityIdentifier.TabBar.exploreTab).firstMatch
      
            XCTAssertTrue(feedsTab.exists || app.tabBars.buttons["Feeds"].exists, "Feeds tab doesn't exist")
            XCTAssertTrue(favoritesTab.exists || app.tabBars.buttons["Favorites"].exists, "Favorites tab doesn't exist")
            XCTAssertTrue(exploreTab.exists || app.tabBars.buttons["Explore"].exists, "Explore tab doesn't exist")
            
            XCTAssertTrue(app.navigationBars["RSS Feeds"].exists, "RSS Feeds navigation bar not found")
            
            XCTAssertTrue(app.buttons.matching(identifier: AccessibilityIdentifier.FeedList.addFeedButton).firstMatch.exists ||
                         app.buttons["Add Feed"].exists, "Add Feed button not found")

            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Launch Screen"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            if favoritesTab.exists {
                favoritesTab.tap()
            } else {
                app.tabBars.buttons["Favorites"].tap()
            }
            
            let favoritesAttachment = XCTAttachment(screenshot: app.screenshot())
            favoritesAttachment.name = "Favorites Tab"
            favoritesAttachment.lifetime = .keepAlways
            add(favoritesAttachment)
            
            // Navigate to Explore tab and take a screenshot
            if exploreTab.exists {
                exploreTab.tap()
            } else {
                app.tabBars.buttons["Explore"].tap()
            }
            
            let exploreAttachment = XCTAttachment(screenshot: app.screenshot())
            exploreAttachment.name = "Explore Tab"
            exploreAttachment.lifetime = .keepAlways
            add(exploreAttachment)
        }
}
