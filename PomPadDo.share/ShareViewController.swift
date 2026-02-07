//
//  ShareViewController.swift
//  PomPadDo.share
//
//  Created by Andrey Mikhaylin on 06.02.2026.
//

import Cocoa
import Social

class ShareViewController: SLComposeServiceViewController {

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
        self.title = NSLocalizedString("PomPadDo", comment: "Title of the Social Service")
    
        NSLog("Input Items = %@", self.extensionContext!.inputItems as NSArray)
    }

    override func didSelectPost() {
        guard let inputItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let outputItem = inputItem.copy() as? NSExtensionItem else {
            // Gracefully handle the failure
            let error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: [NSLocalizedDescriptionKey: "Unable to process input item."])
            self.extensionContext?.cancelRequest(withError: error)
            return
        }
        outputItem.attributedContentText = NSAttributedString(string: self.contentText)
        let outputItems = [outputItem]
        self.extensionContext?.completeRequest(returningItems: outputItems, completionHandler: nil)
    }

    override func didSelectCancel() {
        // Cleanup
    
        // Notify the Service was cancelled
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

    override func isContentValid() -> Bool {
        let messageLength = self.contentText.trimmingCharacters(in: CharacterSet.whitespaces).utf8.count
        let charactersRemaining = 140 - messageLength
        self.charactersRemaining = charactersRemaining as NSNumber
        
        if charactersRemaining >= 0 {
            return true
        }
        
        return false
    }

}
