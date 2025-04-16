//
//  TabBarViewModelKey.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//


import SwiftUI

private struct ResetTriggerValueKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct TabBarViewModelKey: EnvironmentKey {
    static var defaultValue: TabBarViewModel { TabBarViewModel() }
}

extension EnvironmentValues {
    public var resetTriggerValue: Bool {
        get { self[ResetTriggerValueKey.self] }
        set { self[ResetTriggerValueKey.self] = newValue }
    }
    
    public var tabBarViewModel: TabBarViewModel {
        get { self[TabBarViewModelKey.self] }
        set { self[TabBarViewModelKey.self] = newValue }
    }
}
