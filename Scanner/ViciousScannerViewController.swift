//
//  ViewController.swift
//  Scanner
//
//  Created by Ráchel Polachová on 19/09/2021.
//

import UIKit
import AVFoundation
import MLKitVision
import MessageUI

class ViciousScannerViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var checkmarkImage: UIImageView! {
        didSet {
            self.checkmarkImage.isHidden = true
        }
    }
    @IBOutlet weak var counterLabel: UILabel!
    private let session = AVCaptureSession()
    private var scannerManager: BarcodeScanningManaging?
    private var codes = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerManager = BarcodeScanningManager()
        self.startLiveVideo()
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        self.createCsv()
    }
}

// MARK: - Private methods
private extension ViciousScannerViewController {
    
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
    
    func createCsv() {
        var csvString = "\("Serial no.")\n\n"
        for code in self.codes {
            csvString = csvString.appending("\(code)\n")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            self.sendViaMail(fileUrl: fileURL)
            
        } catch {
            print("error creating file")
        }
    }
    
    func sendViaMail(fileUrl: URL) {
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self

        //Set the subject
        mailComposer.setSubject("Vicious scanning serial numbers export")

        //set mail body
        mailComposer.setMessageBody("Serial numbers", isHTML: true)
        
        if let fileData = NSData(contentsOfFile: fileUrl.path) {
            print("File data loaded.")
            mailComposer.addAttachmentData(fileData as Data, mimeType: "application/csv", fileName: "export.csv")
        }

        self.present(mailComposer, animated: true, completion: nil)
    }
    
    func scanForBarcodes(in image: VisionImage) {
        
        self.scannerManager?.scanBarcodes(in: image, completion: { barcode in
            if let code = barcode {
                self.codes.insert(code)
                self.counterLabel.text = "\(self.codes.count)"
                self.showCheckmarkImage(with: .green)
            }
        })
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
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViciousScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = self.imageOrientation(deviceOrientation: UIDevice.current.orientation,
                                                        cameraPosition: .back)
        self.scanForBarcodes(in: visionImage)
    }
}

// MARK: - UI methods
extension ViciousScannerViewController {
    
    func showCheckmarkImage(with color: UIColor) {
        DispatchQueue.main.async {
            self.checkmarkImage.tintColor = color
            self.checkmarkImage.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkmarkImage.isHidden = true
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ViciousScannerViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            DispatchQueue.main.async {
                self.showCheckmarkImage(with: .blue)
                self.codes.removeAll()
                self.counterLabel.text = "\(self.codes.count)"
            }
        }
    }
}
