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

    @IBOutlet weak private var ISOSlider: UISlider!
    @IBOutlet weak private var shutterSpeedSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = AVCaptureDevice.backCamera else {
            print("Failed to get camera device, can't continue!")
            return
        }

        setupISOSlider(device.activeFormat)
        setupShutterSpeedSlider(device.activeFormat)
    }

    private func setupISOSlider(captureDeviceFormat: AVCaptureDeviceFormat) {
        ISOSlider.minimumValue = captureDeviceFormat.minISO
        ISOSlider.maximumValue = captureDeviceFormat.maxISO
        ISOSlider.value = AVCaptureISOCurrent
    }

    private func setupShutterSpeedSlider(captureDeviceFormat: AVCaptureDeviceFormat) {
        shutterSpeedSlider.minimumValue = Float(captureDeviceFormat.minExposureDuration.seconds)
        shutterSpeedSlider.maximumValue = Float(captureDeviceFormat.maxExposureDuration.seconds)
        shutterSpeedSlider.value = Float(AVCaptureExposureDurationCurrent.seconds)
    }

    @IBAction func closeTapped(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func focusSliderChanged(slider: UISlider) {
        delegate.adjustmentDelegateDidUpdateFocus(slider.value)
    }

    @IBAction func isoSliderChanged(slider: UISlider) {
        delegate.adjustmentDelegateDidUpdateISO(slider.value)
    }

    @IBAction func shutterSeedSliderChanged(slider: UISlider) {
        delegate.adjustmentDelegateDidUpdateExposureDuration(Float64(slider.value))
    }
}
