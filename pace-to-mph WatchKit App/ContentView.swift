import SwiftUI

// MARK: - Pace Entry

private struct PaceEntry: Identifiable {
    let min: Int
    let sec: Int
    var id: Int { min * 60 + sec }
    var paceMinutes: Double { Double(min) + Double(sec) / 60.0 }
    var label: String { "\(min):\(String(format: "%02d", sec))" }
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
    @State private var selectedUnit: SpeedUnit = .mph

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
                ForEach(SpeedUnit.allCases, id: \.self) { unit in
                    Text(unit.speedLabel).tag(unit)
                }
            }

            ForEach(activePaces) { pace in
                let speed = ConversionEngine.paceToSpeed(pace.paceMinutes)
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
                        Text(ConversionEngine.formatSpeed(speed))
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.green)
                        Text(selectedUnit.speedLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(pace.label) \(selectedUnit.paceLabel) equals \(ConversionEngine.formatSpeed(speed)) \(selectedUnit.speedLabel)")
            }
        }
        .navigationTitle("Reference")
    }
}

// MARK: - Converter Tab

private struct ConverterTab: View {
    @State private var selectedUnit: SpeedUnit = .mph
    @State private var paceMinutes: Int = 8
    @State private var paceSeconds: Int = 0

    private var paceValue: Double {
        Double(paceMinutes) + Double(paceSeconds) / 60.0
    }

    private var speed: Double {
        guard paceValue > 0 else { return 0 }
        return ConversionEngine.paceToSpeed(paceValue)
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
                    ForEach(SpeedUnit.allCases, id: \.self) { unit in
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
                    Text(ConversionEngine.formatSpeed(speed))
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
    @State private var selectedUnit: SpeedUnit = .mph
    @State private var selectedDistance: RaceCalculator.Distance = .fiveK
    @State private var paceMinutes: Int = 8
    @State private var paceSeconds: Int = 0

    private var paceValue: Double {
        Double(paceMinutes) + Double(paceSeconds) / 60.0
    }

    private var finishTimeSeconds: Int {
        guard paceValue > 0, let distance = selectedDistance.distance(unit: selectedUnit) else { return 0 }
        return RaceCalculator.finishTime(paceMinutes: paceValue, distanceInUnits: distance)
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
                    ForEach(SpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.speedLabel).tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 44)
                .clipped()

                // Distance picker
                Picker("Distance", selection: $selectedDistance) {
                    ForEach(RaceCalculator.Distance.standardCases) { d in
                        Text(d.shortLabel).tag(d)
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
                    Text(RaceCalculator.formatDuration(finishTimeSeconds))
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
