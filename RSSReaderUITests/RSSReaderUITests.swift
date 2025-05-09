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
    
    func testAddFeed() throws {
        let feedsTab = app.tabBars.buttons[AccessibilityIdentifier.TabBar.feedsTab]
        feedsTab.tap()
        
        let initialCellCount = app.cells.count
        
        let addFeedButton = app.buttons[AccessibilityIdentifier.FeedList.addFeedButton]
        XCTAssertTrue(addFeedButton.exists, "Add Feed button doesn't exist")
        addFeedButton.tap()
        
        let urlTextField = app.textFields[AccessibilityIdentifier.AddFeed.urlTextField]
        XCTAssertTrue(urlTextField.exists, "URL text field doesn't exist")
        urlTextField.tap()
        urlTextField.typeText("https://feeds.bbci.co.uk/news/world/rss.xml")
        
        let addButton = app.buttons[AccessibilityIdentifier.AddFeed.addButton]
        XCTAssertTrue(addButton.exists, "Add button doesn't exist")
        addButton.tap()
        
        sleep(3)
        
        let errorView = app.images[AccessibilityIdentifier.AddFeed.addViewErrorView]
        
        if errorView.exists {
            let duplicateError = app.staticTexts["Feed already exists"]
            
            if duplicateError.exists {
                if app.buttons["Try Again"].exists {
                    app.buttons["Try Again"].tap()
                }
                
                if app.buttons[AccessibilityIdentifier.AddFeed.cancelButton].exists {
                    app.buttons[AccessibilityIdentifier.AddFeed.cancelButton].tap()
                }
                
                XCTAssertEqual(app.cells.count, initialCellCount, "Feed count changed after adding duplicate feed")
            } else {
                XCTFail("Error occurred while adding feed")
            }
        } else {
            if app.buttons[AccessibilityIdentifier.AddFeed.cancelButton].exists {
                app.buttons[AccessibilityIdentifier.AddFeed.cancelButton].tap()
            }
            
            XCTAssertEqual(app.cells.count, initialCellCount + 1, "Feed count didn't increase after adding feed")
        }
    }

    func testFeedDetails() throws {
        let feedsTab = app.tabBars.buttons[AccessibilityIdentifier.TabBar.feedsTab]
        feedsTab.tap()
        
        if app.cells.count == 0 {
            try testAddFeed()
        }
        
        XCTAssertTrue(app.cells.count > 0, "No feeds available for testing")
        
        app.cells.firstMatch.tap()
        
        sleep(1)
        
        let feedItemsList = app.collectionViews[AccessibilityIdentifier.FeedItems.itemsList]
       
        let feedItemsExist = feedItemsList.exists
        
        XCTAssertTrue(feedItemsExist, "Neither feed items list nor empty state view was found")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testFavoriteFeature() throws {
        let feedsTab = app.tabBars.buttons[AccessibilityIdentifier.TabBar.feedsTab]
        feedsTab.tap()
        
        if app.cells.count == 0 {
            try testAddFeed()
        }
        
        XCTAssertTrue(app.cells.count > 0, "No feeds available for testing")
        
        app.tabBars.buttons[AccessibilityIdentifier.TabBar.favoritesTab].tap()
        let initialFavoritesCount = app.cells.count
        
        app.tabBars.buttons[AccessibilityIdentifier.TabBar.feedsTab].tap()
        
        let cell = app.cells.firstMatch
        
        let favoriteButton = cell.buttons[AccessibilityIdentifier.FeedView.favoriteButton]
        
        XCTAssertTrue(favoriteButton.exists, "Favorite button doesn't exist")
        favoriteButton.tap()
        
        app.tabBars.buttons[AccessibilityIdentifier.TabBar.favoritesTab].tap()
        
        sleep(2)
        
        let newFavoritesCount = app.cells.count
        
        XCTAssertNotEqual(initialFavoritesCount, newFavoritesCount, "Favorites count didn't change after toggling favorite")
        
        app.tabBars.buttons[AccessibilityIdentifier.TabBar.feedsTab].tap()
    }
}
