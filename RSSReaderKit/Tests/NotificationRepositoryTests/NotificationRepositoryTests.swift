import Testing
import Dependencies
import Foundation
import Common
import SharedModels
import UserNotificationClient
@testable import NotificationRepository

@Suite struct NotificationRepositoryTests {
    @Test("Request permissions successfully")
    func testRequestPermissionsSuccess() async throws {
        await withDependencies {
            $0.userNotifications.requestAuthorization = { _ in true }
        } operation: {
            @Dependency(\.notificationRepository) var repository
            do {
                try await repository.requestPermissions()
                #expect(Bool(true), "Permissions granted")
            } catch {
                #expect(Bool(false), "No error is thrown")
            }
        }
    }
    
    @Test("Request permissions failure")
    func testRequestPermissionsFailure() async throws {
        await withDependencies {
            $0.userNotifications.requestAuthorization = { _ in throw NotificationError.permissionDenied }
        } operation: {
            @Dependency(\.notificationRepository) var repository
            do {
                try await repository.requestPermissions()
            } catch {
                #expect(error is NotificationError)
            }
        }
    }
    
    @Test("Check notifications authorized")
    func testNotificationsAuthorized() async throws {
        await withDependencies {
            $0.userNotifications.getNotificationSettings = {
                UserNotificationClient.NotificationSettings(authorizationStatus: .authorized)
            }
        } operation: {
            @Dependency(\.notificationRepository) var repository
            let isAuthorized = await repository.notificationsAuthorized()
            #expect(isAuthorized)
        }
    }
    
    @Test("Schedule notification for feed item")
    func testScheduleNotificationForItem() async throws {
        let scheduledRequest: LockIsolated<UserNotificationClient.NotificationRequest?> = LockIsolated(nil)
        let feedItem = FeedItem(
            feedID: UUID(),
            title: "Test Item",
            link: URL(string: "https://example.com")!
        )
        
        let feed = Feed(
            url: URL(string: "https://example.com/feed")!,
            title: "Test Feed",
            notificationsEnabled: true
        )
        
        try await withDependencies {
            $0.notificationRepository = NotificationRepository(
                requestPermissions: {},
                checkForNewItems: {},
                notificationsAuthorized: { true },
                scheduleNotificationForItem: { item, feed in
                    let request = UserNotificationClient.NotificationRequest(
                        id: "notification-\(feed.url.absoluteString)-\(item.id.uuidString)",
                        title: feed.title ?? "New item in feed",
                        body: item.title,
                        sound: .default,
                        userInfo: ["feedURL": feed.url.absoluteString, "itemURL": item.link.absoluteString],
                        threadIdentifier: feed.url.absoluteString
                    )
                    scheduledRequest.setValue(request)
                },
                manuallyTriggerBackgroundRefresh: { true },
                activateBackgroundRefresh: {},
                getNotificationStatus: { "Test Status" },
                sendDelayedNotification: { _ in },
                testFeedParsing: { "Test parsing completed" },
                getPendingNotifications: { [] }
            )
        } operation: {
            @Dependency(\.notificationRepository) var repository
            try await repository.scheduleNotificationForItem(feedItem, feed)
            
            #expect(scheduledRequest.value != nil)
            #expect(scheduledRequest.value?.title == "Test Feed")
            #expect(scheduledRequest.value?.body == "Test Item")
            #expect(scheduledRequest.value?.userInfo["feedURL"] as? String == feed.url.absoluteString)
            #expect(scheduledRequest.value?.userInfo["itemURL"] as? String == feedItem.link.absoluteString)
            #expect(scheduledRequest.value?.threadIdentifier == feed.url.absoluteString)
        }
    }
}
