import Foundation
@preconcurrency import UserNotifications

public final class NotificationCenterClient {
    public static var shared: NotificationCenterClient { NotificationCenterClient() }
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    public func setup() {
        notificationCenter.delegate = NotificationDelegate.shared
    }
    
    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
}
