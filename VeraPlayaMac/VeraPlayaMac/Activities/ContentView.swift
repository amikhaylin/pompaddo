//
//  ContentView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import SwiftUI
import SwiftData

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case inbox
    case today
}

struct ContentView: View {
//    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    
    @State private var path = NavigationPath()
    @State private var newTaskIsShowing = false
    @State var selectedSideBarItem: SideBarItem = .inbox
    
    @State private var selectedTask: Todo?

    var body: some View {
        NavigationSplitView {
            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                switch item {
                case .inbox:
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "tray.fill")
                            Text("Inbox")
                        }
                    }
                case .today:
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Today")
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                    }

                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
            }
            .sheet(isPresented: $newTaskIsShowing) {
                // TODO: here we show new task sheet
                NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
            }
        } content: {
            switch selectedSideBarItem {
            case .inbox:
                InboxView(selectedTask: $selectedTask)
            case .today:
                TodayView(selectedTask: $selectedTask)
            }
        } detail: {
            VStack {
                if let selectedTask = selectedTask {
                    EditTaskView(task: selectedTask)
                    Spacer()
                } else {
                    Image(systemName: "list.bullet.clipboard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.gray)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
