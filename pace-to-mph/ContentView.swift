import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
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

                Spacer()

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

                    Text(viewModel.inputSuffix)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                // Accent underline
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.green)
                    .frame(height: 2)
                    .frame(maxWidth: 200)
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
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    private var unitPicker: some View {
        HStack(spacing: 16) {
            ForEach(SpeedUnit.allCases, id: \.self) { u in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.switchUnit(to: u)
                    }
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
            }
        }
    }
}

#Preview {
    ContentView()
}
