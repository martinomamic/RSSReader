//
//  NotificationDebugView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 18.04.25.
//

import Common
import Dependencies
import SwiftUI

@MainActor
public struct NotificationDebugView: View {
    private enum Section {
        case status
        case actions
        case results
    }

    @State public var isRefreshing = false
    @State public var refreshResult = ""
    @State public var notificationStatus = "Unknown"
    @Environment(\.scenePhase) private var scenePhase
    @Dependency(\.notificationRepository) private var notificationRepository

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

private extension NotificationDebugView {
    var header: some View {
        Text(LocalizedStrings.NotificationDebug.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var statusSection: some View {
        VStack(alignment: .leading, spacing: Constants.UI.debugSectionSpacing) {
            Text(LocalizedStrings.NotificationDebug.status)
                .font(.headline)

            HStack {
                Text(LocalizedStrings.NotificationDebug.notificationStatus)
                    .fontWeight(.medium)

                Text(notificationStatus)
                    .foregroundStyle(statusColor)
                    .fontWeight(.semibold)

                Spacer()

                Button(LocalizedStrings.NotificationDebug.check, action: checkNotificationStatus)
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
            Text(LocalizedStrings.NotificationDebug.actions)
                .font(.headline)

            Group {
                actionButton(
                    title: LocalizedStrings.NotificationDebug.requestPermissions,
                    icon: "bell.badge",
                    action: requestPermissions
                )

                actionButton(
                    title: LocalizedStrings.NotificationDebug.sendDelayed,
                    icon: "clock",
                    action: sendDelayedNotification,
                    accentColor: .blue,
                    backgroundApp: true
                )

                actionButton(
                    title: LocalizedStrings.NotificationDebug.triggerRefresh,
                    icon: "arrow.clockwise",
                    action: triggerManualRefresh,
                    accentColor: .green
                )

                actionButton(
                    title: LocalizedStrings.NotificationDebug.testParsing,
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
            Text(LocalizedStrings.NotificationDebug.results)
                .font(.headline)

            Group {
                if isRefreshing {
                    HStack {
                        ProgressView()
                        Text(LocalizedStrings.NotificationDebug.processing)
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
            notificationStatus = await notificationRepository.getNotificationStatus()
            listScheduledNotifications()
        }
    }

    func listScheduledNotifications() {
        Task {
            let pendingRequests = await notificationRepository.getPendingNotifications()
            for (index, request) in pendingRequests.enumerated() {
                print("[\(index)] \(request)")
            }
        }
    }

    func requestPermissions() {
        Task {
            do {
                _ = try await notificationRepository.requestPermissions()
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

            let success = await notificationRepository.manuallyTriggerBackgroundRefresh()

            isRefreshing = false
            if success {
                let timestamp = Date().formatted(date: .numeric, time: .standard)
                refreshResult = "✅ Background refresh triggered successfully at \(timestamp)"
            } else {
                refreshResult = "❌ Background refresh failed"
            }
        }
    }
    
    func sendDelayedNotification() {
        Task {
            do {
                try await notificationRepository.sendDelayedNotification(
                    Int(Constants.UI.debugDelayedNotificationTime)
                )
                refreshResult = "✅ Delayed notification scheduled"
                listScheduledNotifications()
            } catch {
                refreshResult = "❌ Failed to schedule delayed notification: \(error.localizedDescription)"
            }
        }
    }
    
    func testFeedParsing() {
        Task {
            isRefreshing = true
            refreshResult = "Testing feed parsing..."
            
            let results = await notificationRepository.testFeedParsing()
            refreshResult = results
            
            isRefreshing = false
        }
    }
}

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
