import Foundation
import SwiftData

@Model
final class StoredRunWorkout {
    @Attribute(.unique) var healthKitUUIDString: String
    var startDate: Date
    var endDate: Date
    var distanceMeters: Double
    var duration: TimeInterval
    var source: String
    var syncedAt: Date

    init(run: RunWorkout, syncedAt: Date = Date()) {
        healthKitUUIDString = run.id.uuidString
        startDate = run.startDate
        endDate = run.endDate
        distanceMeters = run.distanceMeters
        duration = run.duration
        source = run.source
        self.syncedAt = syncedAt
    }

    var runWorkout: RunWorkout? {
        guard let id = UUID(uuidString: healthKitUUIDString) else { return nil }
        return RunWorkout(
            id: id,
            startDate: startDate,
            endDate: endDate,
            distanceMeters: distanceMeters,
            duration: duration,
            source: source
        )
    }

    func update(from run: RunWorkout, syncedAt: Date = Date()) {
        healthKitUUIDString = run.id.uuidString
        startDate = run.startDate
        endDate = run.endDate
        distanceMeters = run.distanceMeters
        duration = run.duration
        source = run.source
        self.syncedAt = syncedAt
    }
}

@Model
final class RunSyncState {
    @Attribute(.unique) var key: String
    var anchorData: Data?
    var didRequestAuthorization: Bool
    var lastSyncedAt: Date?

    init(
        key: String,
        anchorData: Data? = nil,
        didRequestAuthorization: Bool = false,
        lastSyncedAt: Date? = nil
    ) {
        self.key = key
        self.anchorData = anchorData
        self.didRequestAuthorization = didRequestAuthorization
        self.lastSyncedAt = lastSyncedAt
    }
}
