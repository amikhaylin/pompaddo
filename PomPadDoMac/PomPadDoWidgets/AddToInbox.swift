//
//  AddToInbox.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 23.07.2024.
//

import WidgetKit
import SwiftUI

struct AddToInboxEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        #if os(iOS)
        case .systemSmall:
            VStack {
                Text("Add Task")
                    .font(.title)
                Text("to Inbox")
                
                Image(systemName: "tray.and.arrow.down.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.orange)
                    .widgetURL(URL(string: "pompaddo://addtoinbox"))
            }
            #endif
        default:
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
}

struct AddToInbox: Widget {
    let kind: String = "AddToInbox"

    var body: some WidgetConfiguration {
        #if os(iOS)
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AddToInboxEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AddToInboxEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("PomPadDo add to Inbox")
        .description("This is a widget to display Add to Inbox dialog")
        .supportedFamilies([.systemSmall,
                            .accessoryCircular])
        #else
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                AddToInboxEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AddToInboxEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("PomPadDo add to Inbox")
        .description("This is a widget to display Add to Inbox dialog")
        .supportedFamilies([.accessoryCorner,
                            .accessoryCircular])
        #endif
    }
}

#Preview(as: .accessoryCircular) {
    AddToInbox()
} timeline: {
    SimpleEntry(date: .now)
}
