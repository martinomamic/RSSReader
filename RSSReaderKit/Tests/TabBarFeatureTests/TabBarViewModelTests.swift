//
//  TabBarViewModelTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 29.04.25.
//

import Testing
import SwiftUI
import Common

@testable import TabBarFeature

@MainActor
@Suite struct TabBarViewModelTests {
    
    @Test("Initial selected tab is feeds")
    func testInitialSelectedTab() {
        let viewModel = TabBarViewModel()
        
        #expect(viewModel.selectedTab == .feeds)
    }
    
    @Test("GetIcon returns correct icon for selected tab")
    func testGetIconForSelectedTab() {
        let viewModel = TabBarViewModel()
        
        // Initially feeds should be selected
        #expect(viewModel.selectedTab == .feeds)
        
        // Selected tab should return filled icon
        #expect(viewModel.getIcon(for: .feeds) == "newspaper.fill")
        

        #expect(viewModel.getIcon(for: .explore) == "globe")
        #expect(viewModel.getIcon(for: .favorites) == "star")
        #expect(viewModel.getIcon(for: .debug) == "ladybug")
    }
    
    @Test("GetIcon updates when selected tab changes")
    func testGetIconUpdatesWithSelectedTab() {
        let viewModel = TabBarViewModel()
        
        // Initially feeds tab is selected
        #expect(viewModel.getIcon(for: .feeds) == "newspaper.fill")
        #expect(viewModel.getIcon(for: .explore) == "globe")
        
        // Change selected tab to explore
        viewModel.selectedTab = .explore
        
        // Now explore should have filled icon
        #expect(viewModel.getIcon(for: .feeds) == "newspaper")
        #expect(viewModel.getIcon(for: .explore) == "globe.fill")
        
        // Change to favorites
        viewModel.selectedTab = .favorites
        
        // Now favorites should have filled icon
        #expect(viewModel.getIcon(for: .feeds) == "newspaper")
        #expect(viewModel.getIcon(for: .explore) == "globe")
        #expect(viewModel.getIcon(for: .favorites) == "star.fill")
    }
    
    @Test("GetTitle returns correct title for each tab")
    func testGetTitle() {
        let viewModel = TabBarViewModel()
        
        #expect(viewModel.getTitle(for: .feeds) == LocalizedStrings.TabBar.feeds)
        #expect(viewModel.getTitle(for: .explore) == LocalizedStrings.TabBar.explore)
        #expect(viewModel.getTitle(for: .favorites) == LocalizedStrings.TabBar.favorites)
        #expect(viewModel.getTitle(for: .debug) == LocalizedStrings.TabBar.debug)
    }
    
    @Test("Tab titles remain consistent regardless of selected tab")
    func testTitleConsistency() {
        let viewModel = TabBarViewModel()
        
        let feedsTitle = viewModel.getTitle(for: .feeds)
        
        viewModel.selectedTab = .explore
        #expect(viewModel.getTitle(for: .feeds) == feedsTitle)
        
        viewModel.selectedTab = .favorites
        #expect(viewModel.getTitle(for: .feeds) == feedsTitle)
        
        viewModel.selectedTab = .debug
        #expect(viewModel.getTitle(for: .feeds) == feedsTitle)
    }
}
