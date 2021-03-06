//
//  ContentViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/24/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit
import AsciiConverter
import  Firebase

protocol ContentDelegate {
    func close()
    func new()
}

class ContentViewController: AsciiViewController {

    // MARK: - Setup
    var delegate: ContentDelegate!
    var dataID: String?
    
    @IBOutlet open weak var scrollView: UIScrollView!
    @IBOutlet weak var busyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport(for: scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getAscii()
    }
    
    func getAscii() {
        if dataID != nil {
            busyView.isHidden = false
            Database.database().reference().child("asciiArt").child(dataID!).observeSingleEvent(of: .value, with: { (snapshot) in
                self.asciiArt = snapshot.value as? String
                
                DispatchQueue.main.async {
                    self.busyView.isHidden = true
                    if self.asciiArt != nil {
                        self.displayAsciiArt(self.asciiArt!)
                    } else {
                        self.serverErrorAlert()
                    }
                }
            })
        } else {
            serverErrorAlert()
        }
    }
    
    // MARK: - Actions
    @IBAction func save(_ sender: UIButton) {
        showShareMenu(sender)
    }
    
    @IBAction func new(_ sender: UIButton) {
        self.delegate.new()
    }
    
    // MARK: - UIAlertController
    func showShareMenu(_ sender: UIButton) {
        let share = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = self.asciiArt
            self.alert(title: "Copied!", message: nil, dismissText: "Yay!")
        }
        
        let image = UIAlertAction(title: "Image", style: .default) { action in
            UIImageWriteToSavedPhotosAlbum(self.image(from: self.scrollView)!, nil, nil, nil)
            self.self.alert(title: "Saved!", message: nil, dismissText: "Yay!")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        share.addAction(copy)
        share.addAction(image)
        share.addAction(cancel)
        
        if let popoverController = share.popoverPresentationController {
            // Keep From Crashing On iPad
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        } else {
            // Stop Bottom Bar Overlap on < 12 iPhone
            if #available(iOS 12, *) {
            } else {
                share.view.transform = CGAffineTransform(translationX: 0, y: -40)
            }
        }
        
        present(share, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String?, dismissText: String) {
        let alert = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: dismissText, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func serverErrorAlert() {
        let imageAlert = UIAlertController(title: "ASCII Art Not Found", message:
            "Your ASCII Art Could Not Be Located On The Server", preferredStyle: UIAlertController.Style.alert)
        imageAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            self.delegate.close()
        }))
        
        self.present(imageAlert, animated: true, completion: nil)
    }
}
