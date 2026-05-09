import SwiftUI

struct SettingsView: View {
    @State private var settings = UnitSettings.shared

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(spacing: 20) {
                    unitCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var unitCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("UNITS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            unitPicker
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
    }

    private var unitPicker: some View {
        HStack(spacing: 6) {
            ForEach(SpeedUnit.allCases, id: \.self) { u in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        settings.unit = u
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(u.label)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .tint(settings.unit == u ? .green : nil)
                .accessibilityLabel(u.label)
                .accessibilityAddTraits(settings.unit == u ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Speed unit")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
