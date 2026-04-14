import SwiftUI

struct MainTabsView: View {
    @Binding var tab: MainViewTabs
    @Binding var selectedSideBarItem: SideBarItem?
    @Binding var selectedProject: Project?
    @Binding var activeTasksCount: Int
    @Binding var focusMode: FocusTimerMode
    
    let timer: FocusTimer
    let focusTask: FocusTask
    let refresher: Refresher
    
    @State private var refresh = false
    
    var body: some View {
        TabView(selection: $tab) {
            Tab(value: .tasks) {
                ContentView(selectedSideBarItem: $selectedSideBarItem,
                            selectedProject: $selectedProject,
                            activeTasksCount: $activeTasksCount)
                .id(refresher.refresh)
                .environment(refresher)
                .environment(timer)
                .environment(focusTask)
            } label: {
                Label("Tasks", systemImage: "checkmark.square")
                    .accessibility(identifier: "TasksSection")
            }
            .badge(activeTasksCount)
            
            Tab(value: .focus) {
                FocusTimerView(focusMode: $focusMode)
                    .id(refresh)
                    .environment(timer)
                    .environment(focusTask)
                    .refreshable {
                        refresh.toggle()
                    }
            } label: {
                FocusTabItemView()
                    .environment(timer)
                    .accessibility(identifier: "FocusSection")
            }
            .badge(timer.state != .idle ? Text(verbatim: timer.secondsLeftString) : nil)
            
            Tab(value: .settings) {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
                    .accessibility(identifier: "SettingsSection")
            }
            
            Tab(value: .inbox, role: .search) {
                EmptyView()
            } label: {
                Label("Add to Inbox", systemImage: "tray.and.arrow.down.fill")
                    .foregroundStyle(Color.orange)
                    .accessibility(identifier: "AddTaskToInboxButton")
                    .keyboardShortcut("i", modifiers: [.command])
            }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
