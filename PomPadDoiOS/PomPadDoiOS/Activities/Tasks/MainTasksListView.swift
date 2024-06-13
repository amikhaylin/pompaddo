//
//  MainTasksListView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 12.06.2024.
//

import SwiftUI
import SwiftData

struct MainTasksListView: View {
    @Query var tasks: [Todo]
    @State private var list: SideBarItem
    @State private var title: String
    private var filter: (Todo) -> Bool
    
    var body: some View {
        TasksListView(tasks: tasks
                        .filter(filter)
                        .sorted(by: TasksQuery.defaultSorting),
                      list: list,
                      title: title)
    }
    
    init(predicate: Predicate<Todo>, filter: @escaping (Todo) -> Bool, list: SideBarItem, title: String) {
        _tasks = Query(filter: predicate)
        _list = State(wrappedValue: list)
        _title = State(wrappedValue: title)
        self.filter = filter
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return MainTasksListView(predicate: TasksQuery.predicateInbox(),
                                 filter: { $0.uid == $0.uid },
                                 list: .inbox,
                                 title: "Some list")
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
