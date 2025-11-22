//
//  SectionsListView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData

struct SectionsListView: View {
    @EnvironmentObject var timer: FocusTimer
    @Binding var selectedSideBarItem: SideBarItem?
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    
    var body: some View {
        List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
            switch item {
            case .inbox:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "tray")
                        Text("Inbox")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.4890732765, green: 0.530819118, blue: 0.7039532065, alpha: 1)))
                }
                .accessibilityIdentifier("InboxNavButton")
            case .today:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Today")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.9496305585, green: 0.5398437977, blue: 0.3298020959, alpha: 1)))
                }
                .accessibilityIdentifier("TodayNavButton")
            case .tomorrow:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "sunrise")
                        Text("Tomorrow")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.9219498038, green: 0.2769843042, blue: 0.402439177, alpha: 1)))
                }
            case .alltasks:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "rectangle.stack")
                        Text("All")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.5274487734, green: 0.5852636099, blue: 0.6280642748, alpha: 1)))
                }
            case .focus:
                NavigationLink(value: item) {
                    FocusTabItemView()
                        .environmentObject(timer)
                        .foregroundStyle(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                }
                .accessibilityIdentifier("FocusNavButton")
            case .deadlines:
                if showDeadlinesSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "calendar.badge.exclamationmark")
                            Text("Deadlines")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)))
                    }
                } else {
                    EmptyView()
                }            case .settings:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedSideBarItem: SideBarItem? = .today
    let previewer = try? Previewer()
    
    SectionsListView(selectedSideBarItem: $selectedSideBarItem)
        .modelContainer(previewer!.container)
}
