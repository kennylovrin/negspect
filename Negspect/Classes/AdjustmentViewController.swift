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

    var delegate: AdjustmentDelegate?

    @IBOutlet weak private var visualEffectView: UIVisualEffectView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    @IBOutlet private var rgbSliders: [UISlider]!

    private var filterConfiguration = FilterConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFilterSegmentedControl()
        setupSliders()
    }

    private func setupFilterSegmentedControl() {
        guard let selectedFilter = filterConfiguration.selectedFilter else {
            return
        }

        segmentedControl.selectedSegmentIndex = selectedFilter.rawValue
    }

    private func setupSliders() {
        guard let selectedFilter = filterConfiguration.selectedFilter else {
            return
        }

        for (index, slider) in rgbSliders.enumerate() {
            slider.enabled = selectedFilter == .Color
            slider.value = Float(filterConfiguration.rgbArray[index])
        }
    }

    private func enableSliders(enabled: Bool) {
        for slider in rgbSliders {
            slider.enabled = enabled
        }
    }

    @IBAction func closeTapped(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func segmentedValueChanged(sender: UISegmentedControl) {
        guard let selectedFilter = Filter(rawValue: sender.selectedSegmentIndex) else {
            return
        }

        filterConfiguration.selectedFilter = selectedFilter
        enableSliders(selectedFilter == .Color)

        delegate?.adjustmentViewController(self, didSelectFilter: selectedFilter)
    }

    @IBAction func redSliderChanged(slider: UISlider) {
        let flippedValue = slider.value * Float(-1)
        filterConfiguration.rgbArray[0] = CGFloat(flippedValue)
        delegate?.adjustmentViewController(self, didUpdateRedValue: CGFloat(flippedValue))
    }

    @IBAction func greenSliderChanged(slider: UISlider) {
        let flippedValue = slider.value * Float(-1)
        filterConfiguration.rgbArray[1] = CGFloat(flippedValue)
        delegate?.adjustmentViewController(self, didUpdateGreenValue: CGFloat(flippedValue))
    }

    @IBAction func blueSliderChanged(slider: UISlider) {
        let flippedValue = slider.value * Float(-1)
        filterConfiguration.rgbArray[2] = CGFloat(flippedValue)
        delegate?.adjustmentViewController(self, didUpdateRedValue: CGFloat(flippedValue))
    }

    @IBAction func sliderDidBeginEditing(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.visualEffectView.alpha = 0
        })
    }

    @IBAction func sliderDidEndEditing(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.visualEffectView.alpha = 1
        })
    }
}
