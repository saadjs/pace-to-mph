import SwiftUI

struct ReferenceView: View {
    @State private var selectedUnit: SpeedUnit = .mph

    // Paces from 5:00 to 12:00 in 30-second steps
    private let paces: [(min: Int, sec: Int)] = {
        var result: [(Int, Int)] = []
        for m in 5...12 {
            result.append((m, 0))
            if m < 12 { result.append((m, 30)) }
        }
        return result
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Unit tabs
            Picker("Unit", selection: $selectedUnit) {
                ForEach(SpeedUnit.allCases, id: \.self) { unit in
                    Text(unit.speedLabel).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            List {
                ForEach(paces, id: \.min) { pace in
                    let paceMinutes = Double(pace.min) + Double(pace.sec) / 60.0
                    let speed: Double = {
                        let baseMph = ConversionEngine.paceToSpeed(paceMinutes)
                        return selectedUnit == .mph
                            ? baseMph
                            : ConversionEngine.convertSpeedBetweenUnits(baseMph, from: .mph, to: .kph)
                    }()
                    let paceLabel: String = {
                        if selectedUnit == .mph {
                            return "\(pace.min):\(String(format: "%02d", pace.sec))"
                        }
                        let kmPace = ConversionEngine.convertPaceBetweenUnits(paceMinutes, from: .mph, to: .kph)
                        return ConversionEngine.formatPace(kmPace) ?? "–"
                    }()

                    HStack {
                        Text(paceLabel)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        Text(selectedUnit.paceLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(ConversionEngine.formatSpeed(speed))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.green)

                        Text(selectedUnit.speedLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(paceLabel) \(selectedUnit.paceLabel) equals \(ConversionEngine.formatSpeed(speed)) \(selectedUnit.speedLabel)")
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Reference")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReferenceView()
    }
}
