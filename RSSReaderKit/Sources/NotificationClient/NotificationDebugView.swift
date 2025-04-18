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
    @State private var isRefreshing = false
    @State private var refreshResult = ""
    @State private var notificationStatus = "Unknown"
    @Environment(\.scenePhase) private var scenePhase

    @Dependency(\.notificationClient) private var notificationClient

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.UI.debugViewSpacing) {
                // Header
                Text("Notification Debug")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Status section
                statusSection

                // Actions section
                actionsSection

                // Results section
                resultsSection
            }
            .padding()
        }
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
    }

    // MARK: - UI Sections

    private var statusSection: some View {
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

                Button("Check") {
                    checkNotificationStatus()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            .background(Color.gray.opacity(Constants.UI.debugBackgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.debugCornerRadius))
        }
    }

    private var actionsSection: some View {
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

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: Constants.UI.debugSectionSpacing) {
            Text("Results")
                .font(.headline)

            if isRefreshing {
                HStack {
                    ProgressView()
                    Text("Processing...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }

            Text(refreshResult)
                .multilineTextAlignment(.leading)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(Constants.UI.debugBackgroundOpacity))
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.debugCornerRadius))
                .animation(.easeInOut, value: refreshResult)
        }
    }

    // MARK: - Helper Views

    private func actionButton(
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

    private var statusColor: Color {
        switch notificationStatus {
        case "Authorized":
            return .green
        case "Denied":
            return .red
        default:
            return .orange
        }
    }

    private func moveAppToBackground() {
        Task { try? await Task.sleep(nanoseconds: Constants.UI.debugUIUpdateDelay) }
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
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
                refreshResult = "✅ Notification permissions granted"
                checkNotificationStatus()
            } catch {
                refreshResult = "❌ Failed to get permissions: \(error.localizedDescription)"
            }
        }
    }

    private func triggerManualRefresh() {
        Task {
            isRefreshing = true
            refreshResult = "Refreshing..."

            let success = await BackgroundRefreshClient.shared.manuallyTriggerBackgroundRefresh()

            isRefreshing = false
            if success {
                refreshResult = "✅ Background refresh triggered successfully at \(Date().formatted(date: .numeric, time: .standard))"
                try? await sendConfirmationNotification("Background refresh executed")
            } else {
                refreshResult = "❌ Background refresh failed"
            }
        }
    }

    private func sendDelayedNotification() {
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

                let request = UNNotificationRequest(
                    identifier: "delayed-test-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )

                try await UNUserNotificationCenter.current().add(request)
                refreshResult = "✅ Delayed notification scheduled (will appear in \(Int(Constants.UI.debugDelayedNotificationTime)) seconds)"

                listScheduledNotifications()
            } catch {
                refreshResult = "❌ Failed to schedule delayed notification: \(error.localizedDescription)"
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
                            results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): ✅ \(items.count) items\n"
                        } catch {
                            results += "\(index + 1). \(feed.title ?? feed.url.absoluteString): ❌ Error: \(error)\n"
                            print("Error parsing feed \(feed.url): \(error)")
                        }
                    }
                }

                refreshResult = results
            } catch {
                refreshResult = "❌ Error testing feeds: \(error.localizedDescription)"
                print("Error during feed test: \(error)")
            }

            isRefreshing = false
        }
    }
}
