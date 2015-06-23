//
//  AVCaptureDevice.swift
//  Negspect
//
//  Created by Kenny Lövrin on 23/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    
    static var backCamera: AVCaptureDevice? {
        get {
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
            return devices.filter({ $0.position == .Back }).first
        }
    }
    
}