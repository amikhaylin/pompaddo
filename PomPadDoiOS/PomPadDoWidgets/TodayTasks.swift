//
//  TodayTasks.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 23.07.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct TodayTasksEntryView: View {
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
            .tint(.green)
        }
    }
}

struct TodayTasks: Widget {
    let kind: String = "TodayTasks"
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
        #if os(iOS)
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TodayTasksEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(modelContainer)
            } else {
                TodayTasksEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(modelContainer)
            }
        }
        .configurationDisplayName("PomPadDo today tasks")
        .description("This is a widget to display today tasks number")
        .supportedFamilies([.accessoryCircular,
                            .systemSmall])
        #else
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                TodayTasksEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(modelContainer)
            } else {
                TodayTasksEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(modelContainer)
            }
        }
        .configurationDisplayName("PomPadDo today tasks")
        .description("This is a widget to display today tasks number")
        .supportedFamilies([.accessoryCorner,
                            .accessoryCircular])
        #endif
    }
}

#Preview(as: .accessoryCircular) {
    TodayTasks()
} timeline: {
    SimpleEntry(date: .now)
}
