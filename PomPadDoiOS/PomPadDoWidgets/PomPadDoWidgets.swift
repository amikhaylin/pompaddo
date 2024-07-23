//
//  PomPadDoWidgets.swift
//  PomPadDoWidgets
//
//  Created by Andrey Mikhaylin on 23.07.2024.
//

import WidgetKit
import SwiftUI

struct PomPadDoWidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
    }
}

struct PomPadDoWidgets: Widget {
    let kind: String = "PomPadDoWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PomPadDoWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PomPadDoWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//#Preview(as: .systemSmall) {
//    PomPadDoWidgets()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
