//
//  ProjectToReviewView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 04.06.2024.
//

import SwiftUI

struct ProjectToReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @Bindable var project: Project
    @State private var deletionRequested = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Delete project", role: .destructive) {
                    deletionRequested.toggle()
                }
                .popover(isPresented: $deletionRequested, attachmentAnchor: .point(.top)) {
                    VStack {
                        Text("This project will be permanently deleted")
                        Button(role: .destructive) {
                            project.deleteRelatives(context: modelContext)
                            modelContext.delete(project)
                            deletionRequested.toggle()
                            if showInspector.on {
                                showInspector.on = false
                            }
                            
                            if selectedTasks.tasks.count > 0 {
                                selectedTasks.tasks.removeAll()
                            }
                            
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("Delete Project", systemImage: "trash")
                        }
                    }
                    .padding(10)
                    .presentationCompactAdaptation(.popover)
                }
                
                Button("Mark Reviewed") {
                    project.reviewDate = Date()
                    if showInspector.on {
                        showInspector.on = false
                    }
                    
                    if selectedTasks.tasks.count > 0 {
                        selectedTasks.tasks.removeAll()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(5)
            ProjectView(project: project)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var project = previewer.project
        
        return ProjectToReviewView(project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
