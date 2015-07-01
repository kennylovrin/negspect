//
//  AdjustmentViewController.swift
//  Negspect
//
//  Created by Erik Alfredsson on 29/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit
import AVFoundation

class AdjustmentViewController: UIViewController {

    var delegate: AdjustmentDelegate!

    @IBOutlet weak private var segmentedControl: UISegmentedControl!

    private var filterConfiguration = FilterConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFilterSegmentedControl()
    }

    private func setupFilterSegmentedControl() {
        guard let selectedFilter = filterConfiguration.selectedFilter else {
            return
        }

        segmentedControl.selectedSegmentIndex = selectedFilter.rawValue
    }

    @IBAction func closeTapped(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func segmentedValueChanged(sender: UISegmentedControl) {
        guard let selectedFilter = Filter(rawValue: sender.selectedSegmentIndex) else {
            return
        }

        filterConfiguration.selectedFilter = selectedFilter
        delegate.adjustmentViewController(self, didSelectFilter: selectedFilter)
    }
}
