//
//  NotificationDebugView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import Dependencies
import SwiftUI
@preconcurrency import UserNotifications

@MainActor
public struct NotificationDebugView: View {
    @State private var isRefreshing = false
    @State private var refreshResult = ""
    @State private var notificationStatus = "Unknown"
    
    @Dependency(\.notificationClient) private var notificationClient
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Notification Debug")
                .font(.title)
                .padding(.top)
            
            Text("Notification Status: \(notificationStatus)")
                .padding()
            
            Button("Check Notification Status") {
                checkNotificationStatus()
            }
            .buttonStyle(.bordered)
            
            Button("Request Notification Permissions") {
                requestPermissions()
            }
            .buttonStyle(.bordered)
            
            Button("Trigger Manual Background Refresh") {
                triggerManualRefresh()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRefreshing)
            
            Button("Send Delayed (5 sec) Notification") {
                sendDelayedNotification()
            }
            .buttonStyle(.bordered)
            .disabled(isRefreshing)
            
            Button("Test Feed Parsing") {
                testFeedParsing()
            }
            .buttonStyle(.bordered)
            .disabled(isRefreshing)
            
            if isRefreshing {
                ProgressView()
                    .padding()
            }
            
            Text(refreshResult)
                .padding()
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private func checkNotificationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            switch settings.authorizationStatus {
            case .authorized:
                notificationStatus = "Authorized"
                listScheduledNotifications()
            case .denied:
                notificationStatus = "Denied"
            case .notDetermined:
                notificationStatus = "Not Determined"
            case .provisional:
                notificationStatus = "Provisional"
            case .ephemeral:
                notificationStatus = "Ephemeral"
            @unknown default:
                notificationStatus = "Unknown"
            }
        }
    }
    
    private func listScheduledNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let pendingRequests = await center.pendingNotificationRequests()
            print("Pending notifications: \(pendingRequests.count)")
            for (index, request) in pendingRequests.enumerated() {
                print("[\(index)] \(request.identifier): \(request.content.title) - \(request.content.body)")
            }
        }
    }
    
    private func requestPermissions() {
        Task {
            do {
                try await notificationClient.requestPermissions()
                refreshResult = "Notification permissions granted"
                checkNotificationStatus()
            } catch {
                refreshResult = "Failed to get permissions: \(error.localizedDescription)"
            }
        }
    }
    
    private func triggerManualRefresh() {
        Task {
            isRefreshing = true
            refreshResult = "Refreshing..."
            
            let success = await BackgroundRefreshService.shared.manuallyTriggerBackgroundRefresh()
            
            isRefreshing = false
            if success {
                refreshResult = "Background refresh triggered successfully at \(Date().formatted(date: .numeric, time: .standard))"
                try? await sendConfirmationNotification("Background refresh executed")
            } else {
                refreshResult = "Background refresh failed"
            }
        }
    }
    
    private func sendDelayedNotification() {
        Task {
            do {
                let content = UNMutableNotificationContent()
                content.title = "Delayed Test Notification"
                content.body = "This notification was scheduled 5 seconds ago"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "delayed-test-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                try await UNUserNotificationCenter.current().add(request)
                refreshResult = "Delayed notification scheduled (will appear in 5 seconds)"
                
                // Log pending notifications after scheduling
                listScheduledNotifications()
            } catch {
                refreshResult = "Failed to schedule delayed notification: \(error.localizedDescription)"
            }
        }
    }
    
    private func sendConfirmationNotification(_ context: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification: \(context)"
        content.body = "This is a test notification sent at \(Date().formatted(date: .numeric, time: .standard))"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        try await UNUserNotificationCenter.current().add(request)
        print("Requested notification with title: \(content.title)")
        
        listScheduledNotifications()
    }
    
    private func testFeedParsing() {
        Task {
            isRefreshing = true
            refreshResult = "Testing feed parsing..."
            
            @Dependency(\.persistenceClient) var persistenceClient
            @Dependency(\.rssClient) var rssClient
            
            do {
                var results = ""
                
                let feeds = try await persistenceClient.loadFeeds()
                results += "\nStored feeds: \(feeds.count)\n"
                
                if feeds.isEmpty {
                    results += "No stored feeds to test\n"
                } else {
                    for (index, feed) in feeds.enumerated() {
                        do {
                            let items = try await rssClient.fetchFeedItems(feed.url)
                            results += "\(index+1). \(feed.title ?? feed.url.absoluteString): ✅ \(items.count) items\n"
                        } catch {
                            results += "\(index+1). \(feed.title ?? feed.url.absoluteString): ❌ Error: \(error)\n"
                            print("Error parsing feed \(feed.url): \(error)")
                        }
                    }
                }
                
                refreshResult = results
            } catch {
                refreshResult = "Error testing feeds: \(error.localizedDescription)"
                print("Error during feed test: \(error)")
            }
            
            isRefreshing = false
        }
    }
}
