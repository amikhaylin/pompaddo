//
//  SafariExtensionViewController.swift
//  PomPadDoExt
//
//  Created by Andrey Mikhaylin on 29.05.2024.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var linkTextField: NSTextField!
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width: 330, height: 150)
        return shared
    }()

    @IBAction func okBtnAction(_ sender: Any) {
        
        dismissPopover()
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        dismissPopover()
    }
}
