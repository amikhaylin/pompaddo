//
//  ShareViewController.swift
//  PomPadDo.mobile.share
//
//  Created by Andrey Mikhaylin on 31.01.2026.
//

//import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers

// MARK: - UIKit Interface
class ShareViewController: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let extensionContext else {
            // Exit if we weren't provided a context to work with
            return
        }

        setupShareView(with: extensionContext)
    }

    private func setupShareView(with context: NSExtensionContext) {
        let contentView = UIHostingController(
            rootView: ShareView(context: context)
        )
        // Add the SwiftUI view as a child of ShareViewController
        addChild(contentView)
        view.addSubview(contentView.view)

        // Pin the child view to its parent
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - App Extension Utilities

enum ShareExtensionError: Error {
    case noAttachmentsMatchingType(UTType)
    case itemTypecastFailed(UTType)
}

extension NSExtensionContext {

        /// Attempts extracting the first attachment from the current context
        /// that matches the provided Uniform Type.
    func firstAttachment(ofType type: UTType) throws -> NSItemProvider {
        guard let firstItem = inputItems.first as? NSExtensionItem,
              let attachments = firstItem.attachments,
              let attachment = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(type.identifier) }) else {
            throw ShareExtensionError.noAttachmentsMatchingType(type)
        }
        return attachment
    }
}

extension NSItemProvider {
    func loadURL() async throws -> URL {
        let uniformType = UTType.url

        let loadedItem = try await loadItem(forTypeIdentifier: uniformType.identifier)
        guard let url = loadedItem as? URL else {
            throw ShareExtensionError.itemTypecastFailed(uniformType)
        }
        return url
    }

    func loadImage() async throws -> UIImage {
        let uniformType = UTType.image

                // Make image loading async by wrapping the loadDataRepresentation(for:)
                // API with withCheckedThrowingContinuation
        return try await withCheckedThrowingContinuation { continuation in
            _ = loadDataRepresentation(for: uniformType) { imageData, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let imageData, let image = UIImage(data: imageData) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: ShareExtensionError.itemTypecastFailed(uniformType))
                }
            }
        }
    }
}
