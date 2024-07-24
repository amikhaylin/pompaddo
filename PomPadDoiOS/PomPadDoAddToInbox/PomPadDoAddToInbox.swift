//
//  PomPadDoAddToInbox.swift
//  PomPadDoAddToInbox
//
//  Created by Andrey Mikhaylin on 22.07.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct PomPadDoAddToInboxEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            Image(systemName: "tray.and.arrow.down.fill")
                .resizable()
                .scaledToFit()
                .padding(10)
                .foregroundStyle(Color.orange)
                .widgetURL(URL(string: "pompaddo://addtoinbox"))
        }
    }
}

@main
struct PomPadDoAddToInbox: Widget {
    let kind: String = "PomPadDoAddToInbox"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                PomPadDoAddToInboxEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PomPadDoAddToInboxEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("PomPadDo add to Inbox")
        .description("This is a widget to display Add to Inbox dialog")
        .supportedFamilies([.accessoryCorner,
                            .accessoryCircular])
    }
}

#Preview(as: .accessoryRectangular) {
    PomPadDoAddToInbox()
} timeline: {
    SimpleEntry(date: .now)
}
