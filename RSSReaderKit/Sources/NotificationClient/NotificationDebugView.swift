//
//  NotificationDebugView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import Dependencies
import SwiftUI
import UIKit
@preconcurrency import UserNotifications

@MainActor
public struct NotificationDebugView: View {
    private enum Section {
        case status
        case actions
        case results
    }

    @State private var isRefreshing = false
    @State private var refreshResult = ""
    @State private var notificationStatus = "Unknown"
    @Environment(\.scenePhase) private var scenePhase
    @Dependency(\.notificationClient) private var notificationClient

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.UI.debugViewSpacing) {
                header
                statusSection
                actionsSection
                resultsSection
            }
            .padding()
        }
        .onAppear(perform: checkNotificationStatus)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
    }
}

// MARK: - View Components
private extension NotificationDebugView {
    var header: some View {
        Text("Notification Debug")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var statusSection: some View {
        VStack(alignment: .leading, spacing: Constants.UI.debugSectionSpacing) {
            Text("Status")
                .font(.headline)

            HStack {
                Text("Notification Status:")
                    .fontWeight(.medium)

                Text(notificationStatus)
                    .foregroundStyle(statusColor)
                    .fontWeight(.semibold)

                Spacer()

                Button("Check", action: checkNotificationStatus)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            .padding()
            .background(Color.gray.opacity(Constants.UI.debugBackgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.debugCornerRadius))
        }
    }

    var actionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.UI.debugActionSpacing) {
            Text("Actions")
                .font(.headline)

            Group {
                actionButton(
                    title: "Request Notification Permissions",
                    icon: "bell.badge",
                    action: requestPermissions
                )

                actionButton(
                    title: "Send Delayed (5 sec) Notification",
                    icon: "clock",
                    action: sendDelayedNotification,
                    accentColor: .blue,
                    backgroundApp: true
                )

                actionButton(
                    title: "Trigger Manual Background Refresh",
                    icon: "arrow.clockwise",
                    action: triggerManualRefresh,
                    accentColor: .green
                )

                actionButton(
                    title: "Test Feed Parsing",
                    icon: "doc.text.magnifyingglass",
                    action: testFeedParsing,
                    accentColor: .purple
                )
            }
            .disabled(isRefreshing)
        }
    }

    var resultsSection: some View {
        VStack(alignment: .leading, spacing: Constants.UI.debugSectionSpacing) {
            Text("Results")
                .font(.headline)

            Group {
                if isRefreshing {
                    HStack {
                        ProgressView()
                        Text("Processing...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Text(refreshResult)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(Constants.UI.debugBackgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.debugCornerRadius))
            .animation(.easeInOut, value: refreshResult)
        }
    }

    func actionButton(
        title: String,
        icon: String,
        action: @escaping () -> Void,
        accentColor: Color = .blue,
        backgroundApp: Bool = false
    ) -> some View {
        Button {
            action()
            if backgroundApp {
                moveAppToBackground()
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: Constants.UI.debugIconSize, height: Constants.UI.debugIconSize)
                    .background(accentColor)
                    .clipShape(Circle())

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                if backgroundApp {
                    Image(systemName: "iphone.and.arrow.forward")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding()
        .background(Color.gray.opacity(Constants.UI.debugBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.debugCornerRadius))
    }
}

// MARK: - Helper Properties
private extension NotificationDebugView {
    var statusColor: Color {
        switch notificationStatus {
        case "Authorized": return .green
        case "Denied": return .red
        default: return .orange
        }
    }
}

// MARK: - Actions
private extension NotificationDebugView {
    func moveAppToBackground() {
        Task { try? await Task.sleep(nanoseconds: Constants.UI.debugUIUpdateDelay) }
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }

    func checkNotificationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            notificationStatus = settings.authorizationStatus.description

            if settings.authorizationStatus == .authorized {
                listScheduledNotifications()
            }
        }
    }

    func listScheduledNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let pendingRequests = await center.pendingNotificationRequests()
            print("Pending notifications: \(pendingRequests.count)")
            for (index, request) in pendingRequests.enumerated() {
                print("[\(index)] \(request.identifier): \(request.content.title)")
            }
        }
    }

    func requestPermissions() {
        Task {
            do {
                try await notificationClient.requestPermissions()
                refreshResult = "✅ Notification permissions granted"
                checkNotificationStatus()
            } catch {
                refreshResult = "❌ Failed to get permissions: \(error.localizedDescription)"
            }
        }
    }

    func triggerManualRefresh() {
        Task {
            isRefreshing = true
            refreshResult = "Refreshing..."

            let success = await BackgroundRefreshClient.shared.manuallyTriggerBackgroundRefresh()

            isRefreshing = false
            if success {
                let timestamp = Date().formatted(date: .numeric, time: .standard)
                refreshResult = "✅ Background refresh triggered successfully at \(timestamp)"
                try? await sendConfirmationNotification("Background refresh executed")
            } else {
                refreshResult = "❌ Background refresh failed"
            }
        }
    }
}

// MARK: - Notification Handling
private extension NotificationDebugView {
    func sendDelayedNotification() {
        Task {
            do {
                let content = UNMutableNotificationContent()
                content.title = "Delayed Test Notification"
                content.body = "This notification was scheduled \(Int(Constants.UI.debugDelayedNotificationTime)) seconds ago"
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: Constants.UI.debugDelayedNotificationTime,
                    repeats: false
                )

                try await scheduleTestNotification(content: content, trigger: trigger)
                refreshResult = "✅ Delayed notification scheduled"
                listScheduledNotifications()
            } catch {
                refreshResult = "❌ Failed to schedule delayed notification: \(error.localizedDescription)"
            }
        }
    }

    func sendConfirmationNotification(_ context: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification: \(context)"
        content.body = "Test notification sent at \(Date().formatted(date: .numeric, time: .standard))"
        content.sound = .default

        try await scheduleTestNotification(content: content, trigger: nil)
        listScheduledNotifications()
    }

    func scheduleTestNotification(
        content: UNMutableNotificationContent,
        trigger: UNNotificationTrigger?
    ) async throws {
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        try await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Feed Testing
private extension NotificationDebugView {
    func testFeedParsing() {
        Task {
            isRefreshing = true
            refreshResult = "Testing feed parsing..."

            @Dependency(\.persistenceClient) var persistenceClient
            @Dependency(\.rssClient) var rssClient

            do {
                var results = ""
                let feeds = try await persistenceClient.loadFeeds()
                results += "📊 Stored feeds: \(feeds.count)\n"

                if feeds.isEmpty {
                    results += "ℹ️ No stored feeds to test\n"
                } else {
                    for (index, feed) in feeds.enumerated() {
                        do {
                            let items = try await rssClient.fetchFeedItems(feed.url)
                            let status = "✅ \(items.count) items"
                            results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): \(status)\n"
                        } catch {
                            results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): ❌ Error: \(error)\n"
                        }
                    }
                }

                refreshResult = results
            } catch {
                refreshResult = "❌ Error testing feeds: \(error.localizedDescription)"
            }

            isRefreshing = false
        }
    }
}

// MARK: - UNAuthorizationStatus Description
private extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .notDetermined: return "Not Determined"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}
