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
    @Bindable var project: Project
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Delete project") {
                    project.deleteRelatives(context: modelContext)
                    modelContext.delete(project)
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Mark Reviewed") {
                    project.reviewDate = Date()
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
