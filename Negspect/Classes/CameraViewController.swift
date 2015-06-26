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
        
        let inFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(imageBuffer).takeRetainedValue()
        //var err = vImageCVImageFormat_SetChromaSiting(inFormat, kCVImageBufferChromaLocation_TopLeft)
        //print(err)
        
        var inBuffer = vImage_Buffer()
        inBuffer.data = CVPixelBufferGetBaseAddress(imageBuffer)
        inBuffer.rowBytes = CVPixelBufferGetBytesPerRow(imageBuffer)
        inBuffer.width = vImagePixelCount(CVPixelBufferGetWidth(imageBuffer))
        inBuffer.height = vImagePixelCount(CVPixelBufferGetHeight(imageBuffer))
        
        var outFormat = vImage_CGImageFormat()
        outFormat.bitsPerComponent = 8
        outFormat.bitsPerPixel = 32
        outFormat.bitmapInfo = [CGBitmapInfo.ByteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)]
        outFormat.colorSpace = nil
        
        var err = vImageBuffer_InitWithCVPixelBuffer(
            &inBuffer,
            &outFormat,
            imageBuffer,
            inFormat,
            nil,
            vImage_Flags(kvImagePrintDiagnosticsToConsole)
        )
        print(err)
        
        var bufferData = [UInt8](count: Int(inBuffer.rowBytes) * Int(inBuffer.height), repeatedValue: 0)
        var outBuffer = vImage_Buffer(data: &bufferData, height: inBuffer.height, width: inBuffer.width, rowBytes: inBuffer.rowBytes)
        
        /*err = vImageEqualization_ARGB8888(&inBuffer, &outBuffer, vImage_Flags(kvImageNoFlags));
        print(err)*/
        
        /*err = vImageContrastStretch_ARGB8888(&inBuffer, &outBuffer, vImage_Flags(kvImagePrintDiagnosticsToConsole));
        print(err)*/
        
        //err = vImageConvert_BGRA8888toRGB888(&inBuffer, &outBuffer, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        /*err = vImageBuffer_CopyToCVPixelBuffer(
            &outBuffer,
            &outFormat,
            imageBuffer,
            inFormat,
            nil,
            vImage_Flags(kvImagePrintDiagnosticsToConsole)
        )
        print(err)*/
        
        // create a frame image and tell the view to render
        let orientation = imageOrientationForDeviceOrientation(UIDevice.currentDevice().orientation)
        nextFrame = CIImage(CVPixelBuffer: imageBuffer).imageByApplyingOrientation(orientation)
        previewView?.display()
    }
    
}

