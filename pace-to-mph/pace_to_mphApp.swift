//
//  pace_to_mphApp.swift
//  pace-to-mph
//
//  Created by Saad Bash on 2/28/26.
//

import SwiftUI
import SwiftData

@main
struct pace_to_mphApp: App {
    @State private var healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            AppRootView(healthKitService: healthKitService)
        }
        .modelContainer(for: [StoredRunWorkout.self, RunSyncState.self])
    }
}

private struct AppRootView: View {
    let healthKitService: HealthKitService

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-runHistoryPreview") {
            RunHistoryDebugPreviewView(
                showTrends: ProcessInfo.processInfo.arguments.contains("-runHistoryTrendsPreview")
            )
        } else {
            ContentView(healthKitService: healthKitService)
                .task { await bootstrapHealthKit() }
        }
        #else
        ContentView(healthKitService: healthKitService)
            .task { await bootstrapHealthKit() }
        #endif
    }

    private func bootstrapHealthKit() async {
        healthKitService.configure(modelContext: modelContext)
        await healthKitService.bootstrap()
        if healthKitService.authorizationState == .authorized {
            await healthKitService.refresh()
            healthKitService.startObserving()
        }
    }
}
