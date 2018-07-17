//
//  HomeViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Setup
    var buttonPressed: PicSelectOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToContent" {
            let destination = segue.destination as! DisplayViewController
            destination.picSelectMethod = buttonPressed!
        }
    }

    
    // MARK: - Actions
    @IBAction func homePickImage(_ sender: UIButton) {
        buttonPressed = .pick
        self.performSegue(withIdentifier: "homeToContent", sender: self)
    }

    @IBAction func homeTakePicture(_ sender: UIButton) {
        buttonPressed = .take
        self.performSegue(withIdentifier: "homeToContent", sender: self)
    }

}
