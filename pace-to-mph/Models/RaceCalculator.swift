import Foundation

enum RaceCalculator {
    enum Distance: String, CaseIterable, Identifiable {
        case fiveK = "5K"
        case tenK = "10K"
        case halfMarathon = "Half Marathon"
        case marathon = "Marathon"
        case custom = "Custom"

        var id: String { rawValue }

        var miles: Double? {
            switch self {
            case .fiveK: return 3.10686
            case .tenK: return 6.21371
            case .halfMarathon: return 13.1094
            case .marathon: return 26.2188
            case .custom: return nil
            }
        }

        var kilometers: Double? {
            switch self {
            case .fiveK: return 5.0
            case .tenK: return 10.0
            case .halfMarathon: return 21.0975
            case .marathon: return 42.195
            case .custom: return nil
            }
        }
    }

    /// Given pace (min/mile or min/km) and distance in the same unit, return total seconds.
    static func finishTime(paceMinutes: Double, distanceInUnits: Double) -> Int {
        Int(round(paceMinutes * distanceInUnits * 60))
    }

    /// Format total seconds as "h:mm:ss" or "mm:ss" if under 1 hour.
    static func formatDuration(_ totalSeconds: Int) -> String {
        guard totalSeconds >= 0 else { return "0:00" }
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }

    /// Given finish time (total seconds) and distance, return pace in minutes.
    static func requiredPace(totalSeconds: Int, distanceInUnits: Double) -> Double {
        guard distanceInUnits > 0 else { return 0 }
        return Double(totalSeconds) / 60.0 / distanceInUnits
    }

    /// Parse "h:mm:ss" or "mm:ss" into total seconds, returns nil if invalid.
    static func parseDuration(_ input: String) -> Int? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.split(separator: ":")
        guard !parts.isEmpty, parts.count <= 3 else { return nil }

        let ints = parts.compactMap { Int($0) }
        guard ints.count == parts.count else { return nil }

        switch ints.count {
        case 1:
            // Just minutes
            guard ints[0] >= 0 else { return nil }
            return ints[0] * 60
        case 2:
            // mm:ss
            guard ints[0] >= 0, ints[1] >= 0, ints[1] < 60 else { return nil }
            return ints[0] * 60 + ints[1]
        case 3:
            // h:mm:ss
            guard ints[0] >= 0, ints[1] >= 0, ints[1] < 60, ints[2] >= 0, ints[2] < 60 else { return nil }
            return ints[0] * 3600 + ints[1] * 60 + ints[2]
        default:
            return nil
        }
    }
}
