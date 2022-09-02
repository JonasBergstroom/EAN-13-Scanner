//
//  TorchLight.swift
//  EAN-13 Scanner
//
//  Created by Jonas Bergström on 2022-09-02.
//

import UIKit
import AVFoundation

class TorchLightViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // Flashlight on or off options.
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}
