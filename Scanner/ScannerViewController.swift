//
//  ScannerViewController.swift
//  Scanner
//
//  Created by Ráchel Polachová on 19/09/2021.
//

import UIKit
import AVFoundation
import MLKitVision

protocol ScannerDelegate: AnyObject {
    func scanned(_ code: String)
}

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIImageView!
    
    private var scannerManager: BarcodeScanningManaging?
    private let session = AVCaptureSession()
    
    weak var delegate: ScannerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.scannerManager = BarcodeScanningManager()
        self.startLiveVideo()
    }
}

// MARK: - Private methods
private extension ScannerViewController {
    
    func startLiveVideo() {
        
        self.session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        self.session.addInput(deviceInput)
        self.session.addOutput(deviceOutput)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: self.session)
        imageLayer.frame = CGRect(x: 0, y: 0, width: self.cameraView.frame.size.width + 100, height: self.cameraView.frame.size.height)
        imageLayer.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(imageLayer)
        
        self.session.startRunning()
    }
    
    func imageOrientation(deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        }
    }
    
    func scanForBarcodes(in image: VisionImage) {
        self.scannerManager?.scanBarcodes(in: image, completion: { code in
            if let code = code {
                self.delegate?.scanned(code)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = self.imageOrientation(deviceOrientation: UIDevice.current.orientation,
                                                        cameraPosition: .back)
        self.scanForBarcodes(in: visionImage)
    }
}
