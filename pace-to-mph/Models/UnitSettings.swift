import Foundation
import Observation

@Observable
final class UnitSettings {
    static let shared = UnitSettings()

    static let storageKey = "speedUnit"

    var unit: SpeedUnit {
        didSet {
            guard unit != oldValue else { return }
            UserDefaults.standard.set(unit.rawValue, forKey: Self.storageKey)
        }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        self.unit = SpeedUnit(rawValue: raw) ?? .mph
    }
}
