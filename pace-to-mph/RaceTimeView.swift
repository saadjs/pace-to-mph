import SwiftUI

enum RaceCalculatorMode: String, CaseIterable, Identifiable {
    case paceToTime
    case timeToPace

    var id: String { rawValue }

    var label: String {
        switch self {
        case .paceToTime: return "Pace → Time"
        case .timeToPace: return "Time → Pace"
        }
    }

    var inputTitle: String {
        switch self {
        case .paceToTime: return "PACE"
        case .timeToPace: return "FINISH TIME"
        }
    }

    var resultTitle: String {
        switch self {
        case .paceToTime: return "Finish Time"
        case .timeToPace: return "Target Pace"
        }
    }

    var systemImage: String {
        switch self {
        case .paceToTime: return "timer"
        case .timeToPace: return "figure.run"
        }
    }
}

struct RaceTimeView: View {
    @State private var mode: RaceCalculatorMode = .paceToTime
    @State private var paceInput: String = ""
    @State private var timeInput: String = ""
    @State private var selectedUnit: SpeedUnit = .mph
    @State private var selectedDistance: RaceCalculator.Distance = .fiveK
    @State private var customDistanceInput: String = ""
    @FocusState private var isPaceFocused: Bool
    @FocusState private var isTimeFocused: Bool
    @FocusState private var isDistanceFocused: Bool

    // MARK: - Distance helpers

    private var distanceInSelectedUnit: Double? {
        if selectedDistance == .custom {
            guard let val = Double(customDistanceInput), val > 0 else { return nil }
            return val
        }
        return selectedUnit == .mph ? selectedDistance.miles : selectedDistance.kilometers
    }

    private func distance(in unit: SpeedUnit) -> Double? {
        if selectedDistance == .custom {
            guard let val = Double(customDistanceInput), val > 0 else { return nil }
            return ConversionEngine.convertDistanceBetweenUnits(val, from: selectedUnit, to: unit)
        }
        return selectedDistance.distance(unit: unit)
    }

    // MARK: - Pace → Time outputs

    private var finishTimeText: String {
        guard let pace = ConversionEngine.parsePace(paceInput),
              let distance = distanceInSelectedUnit else { return "" }
        let seconds = RaceCalculator.finishTime(paceMinutes: pace, distanceInUnits: distance)
        return RaceCalculator.formatDuration(seconds)
    }

    private var speedText: String {
        guard let pace = ConversionEngine.parsePace(paceInput) else { return "" }
        let speed = ConversionEngine.paceToSpeed(pace)
        return ConversionEngine.formatSpeed(speed)
    }

    // MARK: - Time → Pace outputs

    private var parsedTimeSeconds: Int? {
        RaceCalculator.parseDuration(timeInput)
    }

    private func targetPace(in unit: SpeedUnit) -> Double? {
        guard let seconds = parsedTimeSeconds,
              let dist = distance(in: unit),
              dist > 0 else { return nil }
        let pace = RaceCalculator.requiredPace(totalSeconds: seconds, distanceInUnits: dist)
        return pace > 0 ? pace : nil
    }

    private func paceText(unit: SpeedUnit) -> String {
        guard let pace = targetPace(in: unit) else { return "" }
        return ConversionEngine.formatPace(pace) ?? ""
    }

    private func speedTextForTargetPace(unit: SpeedUnit) -> String {
        guard let pace = targetPace(in: unit) else { return "" }
        return ConversionEngine.formatSpeed(ConversionEngine.paceToSpeed(pace))
    }

    private var hasTargetPaceResult: Bool {
        targetPace(in: .mph) != nil && targetPace(in: .kph) != nil
    }

    // MARK: - Body

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(spacing: 16) {
                    modePicker
                    inputCard
                    distanceSection
                    resultCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .onTapGesture {
            isPaceFocused = false
            isTimeFocused = false
            isDistanceFocused = false
        }
        .navigationTitle("Race Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(RaceCalculatorMode.allCases) { m in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        mode = m
                        isPaceFocused = false
                        isTimeFocused = false
                    }
                } label: {
                    Label {
                        Text(m.label)
                            .font(.system(size: 15, weight: .semibold))
                    } icon: {
                        Image(systemName: m.systemImage)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                }
                .buttonStyle(.glass)
                .tint(mode == m ? .green : nil)
                .accessibilityAddTraits(mode == m ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Race calculator mode")
    }

    // MARK: - Input Cards

    @ViewBuilder
    private var inputCard: some View {
        switch mode {
        case .paceToTime:
            paceInputCard
        case .timeToPace:
            timeInputCard
        }
    }

    private var paceInputCard: some View {
        VStack(spacing: 16) {
            HStack {
                sectionLabel(mode.inputTitle)

                Spacer()

                unitPicker(style: .pace)
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                TextField("mm:ss", text: $paceInput)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.plain)
                    .focused($isPaceFocused)
                    .minimumScaleFactor(0.5)
                    .onChange(of: paceInput) { _, newValue in
                        paceInput = newValue.filter { $0.isNumber || $0 == ":" || $0 == "." }
                    }

                Text(selectedUnit.paceLabel)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            accentRule
        }
        .padding(24)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
    }

    private var timeInputCard: some View {
        VStack(spacing: 16) {
            sectionLabel(mode.inputTitle)

            TextField("h:mm:ss", text: $timeInput)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .keyboardType(.numbersAndPunctuation)
                .textFieldStyle(.plain)
                .focused($isTimeFocused)
                .minimumScaleFactor(0.5)
                .onChange(of: timeInput) { _, newValue in
                    timeInput = newValue.filter { $0.isNumber || $0 == ":" }
                }

            accentRule
        }
        .padding(24)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
    }

    private var accentRule: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.green)
            .frame(height: 2)
            .frame(maxWidth: 200)
    }

    // MARK: - Unit Picker

    private enum UnitPickerStyle {
        case pace
        case distance
    }

    private func unitPicker(style: UnitPickerStyle) -> some View {
        HStack(spacing: 8) {
            ForEach(SpeedUnit.allCases, id: \.self) { u in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectUnit(u)
                    }
                } label: {
                    Text(unitLabel(for: u, style: style))
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.8)
                        .frame(minWidth: 42)
                }
                .buttonStyle(.glass)
                .tint(selectedUnit == u ? .green : nil)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(style == .pace ? "Pace unit" : "Distance unit")
    }

    // MARK: - Distance Picker

    private var distanceSection: some View {
        VStack(spacing: 14) {
            HStack {
                sectionLabel("DISTANCE")

                Spacer()

                if mode == .timeToPace && selectedDistance == .custom {
                    unitPicker(style: .distance)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RaceCalculator.Distance.allCases) { d in
                        Button {
                            withAnimation(.snappy(duration: 0.25)) {
                                selectedDistance = d
                            }
                        } label: {
                            Text(d.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.glass)
                        .tint(selectedDistance == d ? .green : nil)
                    }
                }
            }

            if selectedDistance == .custom {
                Divider()
                customDistanceField
            }
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
    }

    // MARK: - Custom Distance

    private var customDistanceField: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                TextField("0.0", text: $customDistanceInput)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .focused($isDistanceFocused)
                    .onChange(of: customDistanceInput) { _, newValue in
                        customDistanceInput = newValue.filter { $0.isNumber || $0 == "." }
                    }

                Text(distanceLabel(for: selectedUnit))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

        }
    }

    // MARK: - Result Cards

    @ViewBuilder
    private var resultCard: some View {
        switch mode {
        case .paceToTime:
            finishResultCard
        case .timeToPace:
            targetPaceResultCard
        }
    }

    private var finishResultCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                sectionLabel(mode.resultTitle, alignment: .center)

                Text(finishTimeText.isEmpty ? "–" : finishTimeText)
                    .font(.largeTitle.bold().monospacedDigit())
                    .foregroundStyle(finishTimeText.isEmpty ? .tertiary : .primary)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: finishTimeText)
            }

            if !speedText.isEmpty {
                Divider()

                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("PACE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .tracking(0.6)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(paceInput)
                                .font(.title2.bold().monospacedDigit())
                            Text(selectedUnit.paceLabel)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(spacing: 4) {
                        Text("SPEED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .tracking(0.6)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(speedText)
                                .font(.title2.bold().monospacedDigit())
                                .contentTransition(.numericText())
                                .animation(.snappy(duration: 0.2), value: speedText)
                            Text(selectedUnit.speedLabel)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .sensoryFeedback(.impact(flexibility: .soft), trigger: finishTimeText)
    }

    private var targetPaceResultCard: some View {
        VStack(spacing: 16) {
            sectionLabel(mode.resultTitle, alignment: .center)

            if hasTargetPaceResult {
                HStack(spacing: 0) {
                    paceColumn(unit: .mph)
                    Divider()
                        .frame(height: 72)
                    paceColumn(unit: .kph)
                }
            } else {
                Text("–")
                    .font(.largeTitle.bold().monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .sensoryFeedback(.impact(flexibility: .soft), trigger: paceText(unit: .mph) + paceText(unit: .kph))
    }

    private func paceColumn(unit: SpeedUnit) -> some View {
        let pace = paceText(unit: unit)
        let speed = speedTextForTargetPace(unit: unit)

        return VStack(spacing: 10) {
            Text(unit == .mph ? "MILE" : "KILOMETER")
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(0.6)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(pace.isEmpty ? "–" : pace)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: pace)
                Text(unit.paceLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(speed.isEmpty ? "–" : speed)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: speed)
                Text(unit.speedLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionLabel(_ text: String, alignment: Alignment = .leading) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .tracking(0.6)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    private func unitLabel(for unit: SpeedUnit, style: UnitPickerStyle) -> String {
        switch style {
        case .pace:
            return unit.paceLabel
        case .distance:
            return unit == .mph ? "mi" : "km"
        }
    }

    private func distanceLabel(for unit: SpeedUnit) -> String {
        unit == .mph ? "miles" : "km"
    }

    private func selectUnit(_ unit: SpeedUnit) {
        let previousUnit = selectedUnit
        guard previousUnit != unit else { return }

        paceInput = ConversionEngine.convertPaceInput(paceInput, from: previousUnit, to: unit)
        customDistanceInput = ConversionEngine.convertDistanceInput(customDistanceInput, from: previousUnit, to: unit)
        selectedUnit = unit
    }
}

#Preview {
    NavigationStack {
        RaceTimeView()
    }
}
