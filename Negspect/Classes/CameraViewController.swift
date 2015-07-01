//
//  CameraViewController.swift
//  Negspect
//
//  Created by Kenny Lövrin on 23/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import Accelerate

private let SampleBufferQueue = dispatch_queue_create("SampleBufferQueue", DISPATCH_QUEUE_SERIAL)

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: GLKView?
    
    private let captureSession = AVCaptureSession()
    
    private var context: CIContext?
    private var nextFrame: CIImage?

    private let presentationManager = PresentationManager()

    private var selectedFilter: Filter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContexts()
        configureCaptureSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
}


extension CameraViewController {
    
    private func configureContexts() {
        guard let glContext = EAGLContext(API: .OpenGLES3) else {
            print("Failed to create OpenGL context!")
            return
        }
        
        // connect the gl context of the view to the render context
        // and save the render context for later
        previewView?.context = glContext
        context = CIContext(EAGLContext: glContext, options: nil)
    }
    
    private func configureCaptureSession() {
        // set the preset
        let preset = AVCaptureSessionPresetPhoto
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        }
        
        // get the camera device
        guard let device = AVCaptureDevice.backCamera else {
            print("Failed to get camera device, can't continue!")
            return
        }
        
        // try to set the camera as input
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
            
        } catch let error {
            print("Failed to create device input: \(error)")
            return
        }
        
        // get an output and assign ourselves as delegate
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: SampleBufferQueue)
        output.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey): NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)
        ]
        
        captureSession.addOutput(output)
    }
    
    private func imageOrientationForDeviceOrientation(orientation: UIDeviceOrientation) -> Int32 {
        let orientation: Int32
        
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .Unknown, .FaceUp, .FaceDown:
            orientation = 6
            
        case .PortraitUpsideDown:
            orientation = 8
            
        case .LandscapeLeft:
            orientation = 1
            
        case .LandscapeRight:
            orientation = 3
        }
        
        return orientation
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Adjustment" {
            guard let adjustmentViewController = segue.destinationViewController as? AdjustmentViewController else {
                return
            }
            
            adjustmentViewController.modalPresentationStyle = .Custom
            adjustmentViewController.transitioningDelegate = presentationManager
            adjustmentViewController.delegate = self
        }
    }
    
}


extension CameraViewController: GLKViewDelegate {
    
    func glkView(view: GLKView, drawInRect rect: CGRect) {
        guard let image = nextFrame else {
            return
        }
        
        // scale and fit the frame rect in the view
        let scale = UIScreen.mainScreen().scale
        let transform = CGAffineTransformMakeScale(scale, scale)
        var rect = AVMakeRectWithAspectRatioInsideRect(image.extent.size, rect)
        rect = CGRectApplyAffineTransform(rect, transform)
        
        // draw the frame
        context?.drawImage(image, inRect: rect, fromRect: image.extent)
    }
    
}


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer!")
            return
        }

        var image = CIImage(CVPixelBuffer: imageBuffer)

        if selectedFilter == .Color {
            image = applyColorMatrixFilterToImage(image)
        }

        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setDefaults()
            filter.setValue(image, forKey: kCIInputImageKey)

            if let outImage = filter.valueForKey(kCIOutputImageKey) as? CIImage {
                image = outImage
            }
        }

        // create a frame image and tell the view to render
        let orientation = imageOrientationForDeviceOrientation(UIDevice.currentDevice().orientation)
        nextFrame = image.imageByApplyingOrientation(orientation)
        previewView?.display()
    }

    func applyColorMatrixFilterToImage(image: CIImage) -> CIImage {
        if let filter = CIFilter(name: "CIColorMatrix") {
            filter.setDefaults()
            filter.setValue(image, forKey: kCIInputImageKey)

            filter.setValue(CIVector(x: 0.8, y: 0, z: 0, w: 0), forKey: "inputRVector")
            filter.setValue(CIVector(x: 0, y: 1.7, z: 0, w: 0), forKey: "inputGVector")
            filter.setValue(CIVector(x: 0, y: 0, z: 1.6, w: 0), forKey: "inputBVector")
            filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
            filter.setValue(CIVector(x: 0.3, y: 0.3, z: 0.3, w: 0), forKey: "inputBiasVector")

            if let outImage = filter.valueForKey(kCIOutputImageKey) as? CIImage {
                return outImage
            }
        }

        return image
    }
}

extension CameraViewController: AdjustmentDelegate {

    func adjustmentViewController(adjustmentViewController: AdjustmentViewController, didSelectFilter filter: Filter) {
        selectedFilter = filter
    }
    
}

