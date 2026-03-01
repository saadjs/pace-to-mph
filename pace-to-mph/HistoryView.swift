import SwiftUI

struct HistoryView: View {
    @Bindable var history: ConversionHistory
    @State private var showClearConfirmation = false

    var body: some View {
        Group {
            if history.records.isEmpty {
                ContentUnavailableView {
                    Label("No conversions yet", systemImage: "clock")
                } description: {
                    Text("Your recent conversions will appear here.")
                }
            } else {
                List {
                    ForEach(history.records) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Text(record.input)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .monospacedDigit()
                                    Text(record.inputSuffix)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    Text("→")
                                        .foregroundStyle(.secondary)
                                    Text(record.result)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .monospacedDigit()
                                        .foregroundStyle(.green)
                                    Text(record.resultSuffix)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }

                                Text(record.date, format: .relative(presentation: .named))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(record.input) \(record.inputSuffix) equals \(record.result) \(record.resultSuffix)")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Recent Conversions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !history.records.isEmpty {
                    Button("Clear") {
                        showClearConfirmation = true
                    }
                }
            }
        }
        .alert("Clear History", isPresented: $showClearConfirmation) {
            Button("Clear", role: .destructive) {
                history.clear()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear all conversion history?")
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(history: ConversionHistory())
    }
}
