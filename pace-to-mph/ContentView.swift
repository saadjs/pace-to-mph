import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
    @State private var showCopied = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
                .onTapGesture { isInputFocused = false }

            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Conversion card
                conversionCard
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Reference table
                referenceTable
                    .padding(.top, 12)

                Spacer(minLength: 8)

                // Bottom controls
                controlPanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .containerShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
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

            // Result (tappable to copy)
            Button {
                copyResult()
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Text(viewModel.result.isEmpty ? "–" : viewModel.result)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(viewModel.result.isEmpty ? .tertiary : .primary)
                            .contentTransition(.numericText())
                            .animation(.snappy(duration: 0.2), value: viewModel.result)
                            .opacity(showCopied ? 0.3 : 1)

                        if showCopied {
                            Label("Copied", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }

                    Text(viewModel.resultSuffix)
                        .font(.system(size: 18, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(viewModel.result.isEmpty ? "No result" : "\(viewModel.result) \(viewModel.resultSuffix)")
                .accessibilityHint(viewModel.result.isEmpty ? "" : "Tap to copy")
            }
            .buttonStyle(.plain)
            .disabled(viewModel.result.isEmpty)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }

    // MARK: - Reference Table

    private var referenceTable: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.referenceItems, id: \.pace) { item in
                    VStack(spacing: 4) {
                        Text(item.pace)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text(item.speed)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(item.pace) \(viewModel.unit.paceLabel) equals \(item.speed) \(viewModel.unit.speedLabel)")
                }
            }
            .padding(.horizontal, 24)
        }
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
        .background(
            ContainerRelativeShape()
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            ContainerRelativeShape()
                .strokeBorder(.quaternary, lineWidth: 1)
        )
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
                        .padding(.vertical, 12)
                        .background(
                            viewModel.direction == dir
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.8), Color.green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(Color.clear)
                        )
                        .foregroundStyle(viewModel.direction == dir ? .white : .secondary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(dir.label)
                .accessibilityAddTraits(viewModel.direction == dir ? .isSelected : [])
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color(.tertiarySystemGroupedBackground))
        )
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
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .strokeBorder(
                                    viewModel.unit == u ? Color.green : Color(.separator),
                                    lineWidth: 2
                                )
                        )
                        .foregroundStyle(viewModel.unit == u ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(u.label)
                .accessibilityAddTraits(viewModel.unit == u ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Speed unit")
    }

    // MARK: - Actions

    private func copyResult() {
        guard !viewModel.result.isEmpty else { return }
        UIPasteboard.general.string = "\(viewModel.result) \(viewModel.resultSuffix)"
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.snappy(duration: 0.2)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.snappy(duration: 0.2)) {
                showCopied = false
            }
        }
    }
}

#Preview {
    ContentView()
}
