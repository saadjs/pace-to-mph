import WidgetKit
import SwiftUI

// MARK: - Shared Model

struct WidgetConversionRecord: Codable {
    let id: UUID
    let input: String
    let inputSuffix: String
    let result: String
    let resultSuffix: String
    let date: Date
}

// MARK: - Timeline Entry

struct LastConversionEntry: TimelineEntry {
    let date: Date
    let input: String
    let inputSuffix: String
    let result: String
    let resultSuffix: String
    let isPlaceholder: Bool

    static var empty: LastConversionEntry {
        LastConversionEntry(
            date: .now,
            input: "8:00",
            inputSuffix: "min/mi",
            result: "7.5",
            resultSuffix: "mph",
            isPlaceholder: true
        )
    }
}

// MARK: - Provider

struct LastConversionProvider: TimelineProvider {
    // TODO: Switch to UserDefaults(suiteName: "group.sh.saad.pace-to-mph") once App Group
    // entitlement is added to both the app and widget targets. For now, this reads from
    // UserDefaults.standard which may not reflect the app's data in production, but allows
    // the widget to build and run without entitlement configuration.
    private let storageKey = "conversion_history"

    func placeholder(in context: Context) -> LastConversionEntry {
        .empty
    }

    func getSnapshot(in context: Context, completion: @escaping (LastConversionEntry) -> Void) {
        completion(loadLatestEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LastConversionEntry>) -> Void) {
        let entry = loadLatestEntry()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func loadLatestEntry() -> LastConversionEntry {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let records = try? JSONDecoder().decode([WidgetConversionRecord].self, from: data),
              let latest = records.first else {
            return .empty
        }
        return LastConversionEntry(
            date: .now,
            input: latest.input,
            inputSuffix: latest.inputSuffix,
            result: latest.result,
            resultSuffix: latest.resultSuffix,
            isPlaceholder: false
        )
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: LastConversionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.isPlaceholder {
                Text("No conversions yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(entry.result)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(entry.resultSuffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 2) {
                Image(systemName: "figure.run")
                    .font(.caption2)
                Text("RunPace")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: LastConversionEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "figure.run")
                        .font(.caption)
                    Text("Last Conversion")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if entry.isPlaceholder {
                    Text("No conversions yet")
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(entry.input)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                            Text(entry.inputSuffix)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Image(systemName: "arrow.right")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.result)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Text(entry.resultSuffix)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .minimumScaleFactor(0.6)
                }
                Spacer()
            }
            Spacer()
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Entry View (dispatches by family)

struct LastConversionEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: LastConversionEntry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Definition

struct LastConversionWidget: Widget {
    let kind: String = "LastConversionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LastConversionProvider()) { entry in
            LastConversionEntryView(entry: entry)
        }
        .configurationDisplayName("Last Conversion")
        .description("Shows your most recent pace/speed conversion.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// MARK: - Accessory (Lock Screen) View

struct AccessoryRectangularView: View {
    let entry: LastConversionEntry

    var body: some View {
        if entry.isPlaceholder {
            Text("No conversions")
                .font(.caption)
        } else {
            VStack(alignment: .leading) {
                Text("RunPace")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(entry.input) \(entry.inputSuffix) → \(entry.result) \(entry.resultSuffix)")
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}

// MARK: - Widget Bundle

@main
struct PaceToMphWidgets: WidgetBundle {
    var body: some Widget {
        LastConversionWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    LastConversionWidget()
} timeline: {
    LastConversionEntry(date: .now, input: "8:00", inputSuffix: "min/mi", result: "7.5", resultSuffix: "mph", isPlaceholder: false)
    LastConversionEntry.empty
}

#Preview("Medium", as: .systemMedium) {
    LastConversionWidget()
} timeline: {
    LastConversionEntry(date: .now, input: "8:00", inputSuffix: "min/mi", result: "7.5", resultSuffix: "mph", isPlaceholder: false)
}
