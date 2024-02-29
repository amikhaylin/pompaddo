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
    @Query private var items: [Item]
    
    @State private var path = NavigationPath()
    @State private var newTaskIsShowing = false
    @State var selectedSideBarItem: SideBarItem = .inbox

    var body: some View {
        NavigationSplitView {
            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                switch item {
                case .inbox:
                    NavigationLink {
                        InboxView()
                    } label: {
                        HStack {
                            Image(systemName: "tray.fill")
                            Text("Inbox")
                        }
                    }
                case .today:
                    NavigationLink {
                        InboxView()
                    } label: {
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
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $newTaskIsShowing) {
                // TODO: here we show new task sheet
                NewTaskView(isVisible: self.$newTaskIsShowing)
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
