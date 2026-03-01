import SwiftUI

// MARK: - Shared Types

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

// MARK: - Pace Entry

private struct PaceEntry: Identifiable {
    let min: Int
    let sec: Int
    var id: Int { min * 60 + sec }
    var paceMinutes: Double { Double(min) + Double(sec) / 60.0 }
    var label: String { "\(min):\(String(format: "%02d", sec))" }
}

// MARK: - Race Distances

private enum WatchRaceDistance: String, CaseIterable, Identifiable {
    case fiveK = "5K"
    case tenK = "10K"
    case halfMarathon = "Half"
    case marathon = "Marathon"

    var id: String { rawValue }

    func distance(unit: WatchSpeedUnit) -> Double {
        switch self {
        case .fiveK: return unit == .mph ? 3.10686 : 5.0
        case .tenK: return unit == .mph ? 6.21371 : 10.0
        case .halfMarathon: return unit == .mph ? 13.1094 : 21.0975
        case .marathon: return unit == .mph ? 26.2188 : 42.195
        }
    }
}

private extension View {
    @ViewBuilder
    func watchGlassCard(cornerRadius: CGFloat = 16) -> some View {
        if #available(watchOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func watchGlassButton() -> some View {
        if #available(watchOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

// MARK: - Main View

struct ContentView: View {
    var body: some View {
        ConverterTab()
    }
}

// MARK: - Reference Tab

private struct ReferenceTab: View {
    @State private var selectedUnit: WatchSpeedUnit = .mph

    private let mphPaces: [PaceEntry] = {
        var result: [PaceEntry] = []
        for m in 5...12 {
            result.append(PaceEntry(min: m, sec: 0))
            if m < 12 { result.append(PaceEntry(min: m, sec: 30)) }
        }
        return result
    }()

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
        List {
            Picker("Unit", selection: $selectedUnit) {
                ForEach(WatchSpeedUnit.allCases, id: \.self) { unit in
                    Text(unit.speedLabel).tag(unit)
                }
            }

            ForEach(activePaces) { pace in
                let speed = SharedConversionMath.paceToSpeed(pace.paceMinutes)
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
                        Text(SharedConversionMath.formatSpeed(speed))
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.green)
                        Text(selectedUnit.speedLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(pace.label) \(selectedUnit.paceLabel) equals \(SharedConversionMath.formatSpeed(speed)) \(selectedUnit.speedLabel)")
            }
        }
        .navigationTitle("Reference")
    }
}

// MARK: - Converter Tab

private struct ConverterTab: View {
    @State private var selectedUnit: WatchSpeedUnit = .mph
    @State private var paceMinutes: Int = 8
    @State private var paceSeconds: Int = 0

    private var paceValue: Double {
        Double(paceMinutes) + Double(paceSeconds) / 60.0
    }

    private var speed: Double {
        guard paceValue > 0 else { return 0 }
        return SharedConversionMath.paceToSpeed(paceValue)
    }

    var body: some View {
        NavigationStack {
            converterContent
            .navigationTitle("Converter")
        }
    }

    @ViewBuilder
    private var converterContent: some View {
        if #available(watchOS 26.0, *) {
            GlassEffectContainer {
                converterScrollView
            }
        } else {
            converterScrollView
        }
    }

    private var converterScrollView: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Unit picker
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(WatchSpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.speedLabel).tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 44)
                .clipped()

                // Pace input
                HStack(spacing: 2) {
                    Picker("Min", selection: $paceMinutes) {
                        ForEach(1...30, id: \.self) { m in
                            Text("\(m)").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 55, height: 60)

                    Text(":")
                        .font(.title3.bold())

                    Picker("Sec", selection: $paceSeconds) {
                        ForEach(0..<60, id: \.self) { s in
                            Text(String(format: "%02d", s)).tag(s)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 55, height: 60)

                    Text(selectedUnit.paceLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Speed result
                VStack(spacing: 4) {
                    Text(SharedConversionMath.formatSpeed(speed))
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.green)
                    Text(selectedUnit.speedLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .watchGlassCard()

                Divider()

                VStack(spacing: 8) {
                    NavigationLink("Reference Table") {
                        ReferenceTab()
                    }
                    .watchGlassButton()

                    NavigationLink("Race Calculator") {
                        RaceCalcTab()
                    }
                    .watchGlassButton()
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Race Calculator Tab

private struct RaceCalcTab: View {
    @State private var selectedUnit: WatchSpeedUnit = .mph
    @State private var selectedDistance: WatchRaceDistance = .fiveK
    @State private var paceMinutes: Int = 8
    @State private var paceSeconds: Int = 0

    private var paceValue: Double {
        Double(paceMinutes) + Double(paceSeconds) / 60.0
    }

    private var finishTimeSeconds: Int {
        guard paceValue > 0 else { return 0 }
        let distance = selectedDistance.distance(unit: selectedUnit)
        return Int(round(paceValue * distance * 60))
    }

    var body: some View {
        raceContent
        .navigationTitle("Race Calc")
    }

    @ViewBuilder
    private var raceContent: some View {
        if #available(watchOS 26.0, *) {
            GlassEffectContainer {
                raceScrollView
            }
        } else {
            raceScrollView
        }
    }

    private var raceScrollView: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Unit picker
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(WatchSpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.speedLabel).tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 44)
                .clipped()

                // Distance picker
                Picker("Distance", selection: $selectedDistance) {
                    ForEach(WatchRaceDistance.allCases) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 44)
                .clipped()

                // Pace input
                HStack(spacing: 2) {
                    Picker("Min", selection: $paceMinutes) {
                        ForEach(1...30, id: \.self) { m in
                            Text("\(m)").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 55, height: 60)

                    Text(":")
                        .font(.title3.bold())

                    Picker("Sec", selection: $paceSeconds) {
                        ForEach(0..<60, id: \.self) { s in
                            Text(String(format: "%02d", s)).tag(s)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 55, height: 60)

                    Text(selectedUnit.paceLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Finish time result
                VStack(spacing: 4) {
                    Text("Finish Time")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(SharedConversionMath.formatDuration(finishTimeSeconds))
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .watchGlassCard()
            }
            .padding(.horizontal)
        }
    }
}


#Preview {
    ContentView()
}
