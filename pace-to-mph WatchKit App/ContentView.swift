import SwiftUI

// MARK: - Conversion Logic (self-contained for watch)

private enum WatchSpeedUnit: String, CaseIterable {
    case mph
    case kph

    var paceLabel: String {
        switch self {
        case .mph: return "/mi"
        case .kph: return "/km"
        }
    }

    var speedLabel: String {
        switch self {
        case .mph: return "MPH"
        case .kph: return "KM/H"
        }
    }
}

private func paceToSpeed(_ paceMinutes: Double) -> Double {
    60.0 / paceMinutes
}

private func formatSpeed(_ value: Double) -> String {
    String(format: "%.2f", value)
}

// MARK: - Pace Entry

private struct PaceEntry: Identifiable {
    let min: Int
    let sec: Int
    var id: Int { min * 60 + sec }
    var paceMinutes: Double { Double(min) + Double(sec) / 60.0 }
    var label: String { "\(min):\(String(format: "%02d", sec))" }
}

// MARK: - View

struct ContentView: View {
    @State private var selectedUnit: WatchSpeedUnit = .mph

    // Paces per mile: 5:00–12:00 in 30s steps
    private let mphPaces: [PaceEntry] = {
        var result: [PaceEntry] = []
        for m in 5...12 {
            result.append(PaceEntry(min: m, sec: 0))
            if m < 12 { result.append(PaceEntry(min: m, sec: 30)) }
        }
        return result
    }()

    // Paces per km: 3:00–8:00 in 30s steps
    private let kphPaces: [PaceEntry] = {
        var result: [PaceEntry] = []
        for m in 3...8 {
            result.append(PaceEntry(min: m, sec: 0))
            if m < 8 { result.append(PaceEntry(min: m, sec: 30)) }
        }
        return result
    }()

    private var activePaces: [PaceEntry] {
        selectedUnit == .mph ? mphPaces : kphPaces
    }

    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(WatchSpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.speedLabel).tag(unit)
                    }
                }

                ForEach(activePaces) { pace in
                    let speed = paceToSpeed(pace.paceMinutes)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pace.label)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .monospacedDigit()
                            Text(selectedUnit.paceLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatSpeed(speed))
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(.green)
                            Text(selectedUnit.speedLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(pace.label) \(selectedUnit.paceLabel) equals \(formatSpeed(speed)) \(selectedUnit.speedLabel)")
                }
            }
            .navigationTitle("RunPace")
        }
    }
}

#Preview {
    ContentView()
}
