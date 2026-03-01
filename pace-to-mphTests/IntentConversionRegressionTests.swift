import AppIntents
import Testing
@testable import pace_to_mph

struct IntentConversionRegressionTests {
    private func unpack(_ result: some ReturnsValue<String> & ProvidesDialog) -> IntentResultContainer<String, Never, Never, IntentDialog> {
        result as! IntentResultContainer<String, Never, Never, IntentDialog>
    }

    @Test func paceToSpeedIntentForMph() async throws {
        var intent = PaceToSpeedIntent()
        intent.pace = "8:00"
        intent.unit = .mph

        let result = unpack(try await intent.perform())
        #expect(result.value == "7.50")
        #expect(String(describing: result.dialog).contains("per mile"))
    }

    @Test func paceToSpeedIntentForKph() async throws {
        var intent = PaceToSpeedIntent()
        intent.pace = "8:00"
        intent.unit = .kph

        let result = unpack(try await intent.perform())
        #expect(result.value == "7.50")
        #expect(String(describing: result.dialog).contains("per kilometer"))
    }

    @Test func speedToPaceIntentForMph() async throws {
        var intent = SpeedToPaceIntent()
        intent.speed = 10
        intent.unit = .mph

        let result = unpack(try await intent.perform())
        #expect(result.value == "6:00")
        #expect(String(describing: result.dialog).contains("/mi"))
    }

    @Test func speedToPaceIntentForKph() async throws {
        var intent = SpeedToPaceIntent()
        intent.speed = 12
        intent.unit = .kph

        let result = unpack(try await intent.perform())
        #expect(result.value == "5:00")
        #expect(String(describing: result.dialog).contains("/km"))
    }
}
