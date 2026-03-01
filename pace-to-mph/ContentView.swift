import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            GlassEffectContainer {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Conversion card
                    conversionCard
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer()

                    // Bottom controls
                    controlPanel
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
                .onTapGesture {
                    isInputFocused = false
                    viewModel.recordCurrentConversion()
                }
                .onChange(of: isInputFocused) { _, focused in
                    if !focused {
                        viewModel.recordCurrentConversion()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView(history: viewModel.history)
                    } label: {
                        Image(systemName: "clock")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .accessibilityLabel("Conversion history")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink {
                            RaceTimeView()
                        } label: {
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .accessibilityLabel("Race finish time")

                        NavigationLink {
                            SplitCalculatorView()
                        } label: {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .accessibilityLabel("Even splits calculator")

                        NavigationLink {
                            ReferenceView()
                        } label: {
                            Image(systemName: "table")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .accessibilityLabel("Pace reference table")
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.directionLabel)
                .font(.caption)
                .fontWeight(.bold)
                .tracking(0.6)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .strokeBorder(.quaternary, lineWidth: 1)
                )

            Text(viewModel.helperText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Conversion Card

    private var conversionCard: some View {
        VStack(spacing: 24) {
            // Input
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    TextField(viewModel.placeholder, text: Binding(
                        get: { viewModel.inputText },
                        set: { viewModel.handleInput($0) }
                    ))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .keyboardType(viewModel.direction == .paceToSpeed ? .numbersAndPunctuation : .decimalPad)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .onSubmit { viewModel.recordCurrentConversion() }
                    .minimumScaleFactor(0.5)
                    .accessibilityLabel("Enter \(viewModel.direction == .paceToSpeed ? "pace" : "speed")")
                    .accessibilityHint(viewModel.helperText)

                    Text(viewModel.inputSuffix)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }

                // Accent underline
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.green)
                    .frame(height: 2)
                    .frame(maxWidth: 200)
                    .accessibilityHidden(true)
            }

            // Divider
            Divider()

            // Result
            VStack(spacing: 6) {
                Text(viewModel.result.isEmpty ? "–" : viewModel.result)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(viewModel.result.isEmpty ? .tertiary : .primary)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: viewModel.result)

                Text(viewModel.resultSuffix)
                    .font(.system(size: 18, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(viewModel.result.isEmpty ? "No result" : "\(viewModel.result) \(viewModel.resultSuffix)")
        }
        .padding(24)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        VStack(spacing: 14) {
            // Direction labels
            HStack {
                Text("Conversion")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Units")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
            }

            // Direction picker
            directionPicker

            // Unit picker
            unitPicker
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
    }

    private var directionPicker: some View {
        HStack(spacing: 6) {
            ForEach(ConversionDirection.allCases, id: \.self) { dir in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        isInputFocused = false
                        viewModel.switchDirection(to: dir)
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Text(dir.label)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .tint(viewModel.direction == dir ? .green : nil)
                .accessibilityLabel(dir.label)
                .accessibilityAddTraits(viewModel.direction == dir ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversion direction")
    }

    private var unitPicker: some View {
        HStack(spacing: 16) {
            ForEach(SpeedUnit.allCases, id: \.self) { u in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.switchUnit(to: u)
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(u.label)
                        .font(.system(size: 14, weight: .bold))
                        .tracking(1.5)
                }
                .buttonStyle(.glass)
                .tint(viewModel.unit == u ? .green : nil)
                .accessibilityLabel(u.label)
                .accessibilityAddTraits(viewModel.unit == u ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Speed unit")
    }

}

#Preview {
    ContentView()
}
