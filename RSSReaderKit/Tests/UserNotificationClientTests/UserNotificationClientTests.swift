import Testing
import Dependencies
import Foundation
@testable import UserNotificationClient

@Suite struct UserNotificationClientTests {
    
    @Test("Request authorization returns correct value")
    func testRequestAuthorization() async throws {
        let client = UserNotificationClient.testValue
        let result = try await client.requestAuthorization([.alert, .sound])
        #expect(result)
    }
    
    @Test("Get notification settings returns correct value")
    func testGetNotificationSettings() async throws {
        let client = UserNotificationClient.testValue
        let settings = await client.getNotificationSettings()
        #expect(settings.authorizationStatus == .authorized)
    }
    
    @Test("Add notification request")
    func testAddNotificationRequest() async throws {
        let client = UserNotificationClient.testValue
        let request = UserNotificationClient.NotificationRequest(
            id: "test",
            title: "Test",
            body: "Test body"
        )
        try await client.addNotificationRequest(request)
    }
    
    @Test("Get notification status description")
    func testGetNotificationStatusDescription() async throws {
        let client = UserNotificationClient.testValue
        let status = await client.getNotificationStatusDescription()
        #expect(status == "testStatus")
    }
}
