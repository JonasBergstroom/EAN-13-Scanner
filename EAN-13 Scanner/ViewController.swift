//
//  ViewController.swift
//  EAN-13 Scanner
//
//  Created by Jonas Bergström on 2022-09-01.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var scanScreenView: UIImageView!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var newScanButton: UIButton!
    
    private var torch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
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
    
    @IBAction func flashLight(_ sender: UIButton) {
        torch.toggle()
        toggleTorch(on: torch)
    }

}

