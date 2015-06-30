//
//  AdjustmentViewController.swift
//  Negspect
//
//  Created by Erik Alfredsson on 29/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

class AdjustmentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func closeTapped(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
