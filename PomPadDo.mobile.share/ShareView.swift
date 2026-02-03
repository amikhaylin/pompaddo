//
//  ShareView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 03.02.2026.
//

import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers
import SwiftData

// MARK: - SwiftUI Interface

struct ShareView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var text: String = ""
    @State private var previewImage: Image?
    @State private var link: URL?

    let context: NSExtensionContext

    var body: some View {
        NavigationStack {
            HStack(alignment: .top) {
                    // We'll try auto-populating the TextEditor with the webpage
                    // title, but allow the user to change that as needed.
                TextEditor(text: $text)

                if let previewImage {
                    previewImage
                        .resizable()
                        .frame(width: 80, height: 50)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
            .padding(.horizontal)
            .toolbar {
                    // Setup a navigation bar that mirrors
                    // SLComposeServiceViewController
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancelAction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveAction)
                }
            }
            .task {
                    // Start loading webpage metadata before the view appears
                do {
                    try await loadWebpageMetadata(for: context)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // MARK: Button Actions

    private func cancelAction() {
        enum ShareError: Error {
            case userCancelled
        }
        context.cancelRequest(withError: ShareError.userCancelled)
    }

    private func saveAction() {
        // Return an array of results ([NSExtensionItem]) to the host app
        let task = Todo(name: text)
        if let link = link {
            task.link = link.absoluteString
        }
        modelContext.insert(task)
        
        context.completeRequest(returningItems: [])
    }

    // MARK: Networking

    private func loadWebpageMetadata(
        for context: NSExtensionContext
      ) async throws {
            // Use previously defined extensions to extract the URL
            // from the extension context:
        let url = try await context.firstAttachment(ofType: .url).loadURL()

                // Use Apple's LPMetadataProvider API to extract metadata from the URL:
        let linkMetadataProvider = LPMetadataProvider()
        let metadata = try await linkMetadataProvider.startFetchingMetadata(for: url)

                // Once we extract the metadata, update the UI with available info
        if let webpageTitle = metadata.title {
            text = webpageTitle
        }

        if let imageProvider = metadata.imageProvider,
           let linkPreviewImage = try? await imageProvider.loadImage() {
            previewImage = Image(uiImage: linkPreviewImage)
        }
          
        link = url
    }
}
