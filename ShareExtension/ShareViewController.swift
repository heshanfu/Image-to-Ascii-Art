//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Liam on 7/9/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    // Called after the user selects an image from the photos
    override func didSelectPost() {
        // Make sure we have a valid extension item
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            let itemProvider = content.attachments?.first as? NSItemProvider
            let registeredTypeIdentifiers = itemProvider?.registeredTypeIdentifiers
            let contentType = registeredTypeIdentifiers!.first!
//            let contentType = kUTTypeImage as String
            
            // Verify the provider is valid
            if let contents = content.attachments as? [NSItemProvider] {
                
                // look for images
                for attachment in contents {
                    if attachment.hasItemConformingToTypeIdentifier(contentType) {
                        attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
                            let path = data as! URL
//                            if let imageData = try? Data(contentsOf: path) {
//                                self.saveImage(for: imageData)
//                            }
                            self.openContainerApp(with: path)
                        }
                    }
                }
            }
        }
        
        // Inform the host that we're done, so it un-blocks its UI.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    // Open Main App
    func openContainerApp(with path: URL) {
        let url = URL(string: "ascii://" + String(describing: path))
        let selectorOpenURL = sel_registerName("openURL:")
        let context = NSExtensionContext()
        context.open(url!, completionHandler: nil)
        
        var responder = self as UIResponder?
        
        while (responder != nil){
            if responder?.responds(to: selectorOpenURL) == true{
                responder?.perform(selectorOpenURL, with: url)
                return
            }
            responder = responder!.next
        }
    }
    
    // Saves an image to user defaults.
    func saveImage(for imageData: Data) {
        if let prefs = UserDefaults(suiteName: "group.liamrosenfeld.ImageToAsciiArt") {
            prefs.removeObject(forKey: "passedImage")
            prefs.set(imageData, forKey: "passedImage")
        }
    }

}
