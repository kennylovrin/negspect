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

private let SampleBufferQueue = dispatch_queue_create("SampleBufferQueue", DISPATCH_QUEUE_SERIAL)

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: GLKView?
    
    private let captureSession = AVCaptureSession()
    
    private var context: CIContext?
    private var nextFrame: CIImage?
    

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
        let preset = AVCaptureSessionPresetHigh
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
        
        // create a frame image and tell the view to render
        nextFrame = CIImage(CVPixelBuffer: imageBuffer).imageByApplyingOrientation(6)        
        previewView?.display()
    }
    
}

