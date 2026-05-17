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
        Picker("Speed unit", selection: Binding(
            get: { settings.unit },
            set: { unit in
                settings.unit = unit
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        )) {
            ForEach(SpeedUnit.allCases, id: \.self) { u in
                Text(u.label).tag(u)
            }
        }
        .pickerStyle(.segmented)
        .tint(.green)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
