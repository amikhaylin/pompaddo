//
//  PomPadDoTodayTasks.swift
//  PomPadDoTodayTasks
//
//  Created by Andrey Mikhaylin on 05.07.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TodayTasksEntry {
        TodayTasksEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayTasksEntry) -> Void) {
        let entry = TodayTasksEntry(date: Date())
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [TodayTasksEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let entry = TodayTasksEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TodayTasksEntry: TimelineEntry {
    let date: Date
}

struct PomPadDoTodayTasksEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Query(filter: TasksQuery.predicateToday()) var tasksToday: [Todo]
    
    var body: some View {
       ZStack {
           AccessoryWidgetBackground()
           // Value: completed tasks, in: 0...X (total today tasks)
           Gauge(value: Double(tasksToday.filter({ TasksQuery.checkToday(date: $0.completionDate) && $0.completed }).count), in: 0...Double(tasksToday.filter({ TasksQuery.checkToday(date: $0.completionDate) }).count)) {
               Text("\(tasksToday.filter({ $0.completed == false }).count)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.orange)
        }
    }
}

@main
struct PomPadDoTodayTasks: Widget {
    let kind: String = "PomPadDoTodayTasks"
    let modelContainer: ModelContainer = {
        let schema = Schema([
            Todo.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                PomPadDoTodayTasksEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(modelContainer)
            } else {
                PomPadDoTodayTasksEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(modelContainer)
            }
        }
        .configurationDisplayName("PomPadDo today tasks")
        .description("This is a widget to display today tasks number")
        .supportedFamilies([.accessoryCorner,
                            .accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    PomPadDoTodayTasks()
} timeline: {
    TodayTasksEntry(date: .now)
}
