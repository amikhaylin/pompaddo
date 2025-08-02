//
//  SafariExtensionHandler.swift
//  PomPadDoExt
//
//  Created by Andrey Mikhaylin on 29.05.2024.
//

import SafariServices
import os.log

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        os_log(.default, "The extension received a request for profile: %@", profile?.uuidString ?? "none")
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        page.getPropertiesWithCompletionHandler { properties in
            os_log(.default, "The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, String(describing: properties?.url), userInfo ?? [:])
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        window.getActiveTab { tab in
            tab?.getActivePage(completionHandler: { page in
                page?.getPropertiesWithCompletionHandler({ property in
                    if let prop = property, let title = prop.title, let link = prop.url {
                        NSWorkspace.shared.open(URL(string: "pompaddo://new?title=\(title)&link=\(link.absoluteString)")!)
                    }
                })
            })
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        window.getActiveTab { (tab) in
             tab?.getActivePage(completionHandler: { (page) in
                 page?.getPropertiesWithCompletionHandler({ (properties) in
                     validationHandler(properties?.url != nil, "")
                 })
             })
         }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
