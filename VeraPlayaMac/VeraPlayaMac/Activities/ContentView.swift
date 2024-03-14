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
    @Environment(\.modelContext) private var modelContext
    
    @State private var path = NavigationPath()
    @State private var newTaskIsShowing = false
    @AppStorage("selectedSideBar") var selectedSideBarItem: SideBarItem = .inbox
    
    @State private var selectedTask: Todo?
    
    @Query(filter: TasksQuery.predicate_inbox(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicate_today(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksToday: [Todo]
    
    @State var badgeManager = BadgeManager()

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
                        .badge(tasksInbox.count)
                    }
                    
                case .today:
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Today")
                        }
                        .badge(tasksToday.count)
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
            }
            .sheet(isPresented: $newTaskIsShowing) {
                // TODO: here we show new task sheet
                NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
            }
        } content: {
            switch selectedSideBarItem {
            case .inbox:
                TasksListView(tasks: tasksInbox, selectedTask: $selectedTask, list: selectedSideBarItem)
            case .today:
                TasksListView(tasks: tasksToday, selectedTask: $selectedTask, list: selectedSideBarItem)
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
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 300)
        }
        .onChange(of: tasksToday.count) { oldValue, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onAppear {
            tasksToday.count > 0 ? badgeManager.setBadge(number: tasksToday.count) : badgeManager.resetBadgeNumber()
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return ContentView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
