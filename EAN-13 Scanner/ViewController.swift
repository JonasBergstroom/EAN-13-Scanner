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
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var torch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newScanButton.layer.cornerRadius = 7
        newScanButton.addTarget(self, action: #selector(newScan), for: .touchUpInside)
        StartScanScreen()
        view.isUserInteractionEnabled = true
    
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
    
    func StartScanScreen(){
        
        let metadataOutput = AVCaptureMetadataOutput()

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //Format of the barcode.
            metadataOutput.metadataObjectTypes = [.ean13]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        view.bringSubviewToFront(scanScreenView)
        view.bringSubviewToFront(newScanButton)
        view.bringSubviewToFront(lightButton)
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning this code from the item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    @objc func newScan(){
        StartScanScreen()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            foundBarCode(code: stringValue)
        }

        dismiss(animated: true)
    }
    
    func foundBarCode(code: String) {
        
        let duration: Double = 0.5
        let durationend: Double = 3
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            
            let ac = UIAlertController(title: "Scanning Success!", message: "\(code)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                _ in
            }))
            self.present(ac, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + durationend) {
            self.dismiss(animated: true)
            }
        }
    }
}
