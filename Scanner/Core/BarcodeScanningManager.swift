//
//  BarcodeScanningManager.swift
//  Scanner
//
//  Created by Ráchel Polachová on 19/09/2021.
//

import Foundation
import MLKitVision
import MLKitBarcodeScanning

protocol BarcodeScanningManaging {
    func scanBarcodes(in image: VisionImage, completion: @escaping (String?) -> Void)
}

protocol BarcodeScanningDelegate: NSObject {
    
}

enum BarcodeType {
    
    case serialNumber
    
    var prefix: String {
        switch self {
        case .serialNumber:
            return "S"
        }
    }
}

class BarcodeScanningManager: BarcodeScanningManaging {
    
    private let barcodeScanner: BarcodeScanner
    private let barcodeTypes: [BarcodeType]
    
    weak var delegate: BarcodeScanningDelegate?
    
    convenience init() {
        self.init(barcodeScanner: BarcodeScanner.barcodeScanner(options: BarcodeScannerOptions(formats: .all)),
                  barcodeTypes: [.serialNumber])
    }
    
    init(barcodeScanner: BarcodeScanner, barcodeTypes: [BarcodeType]) {
        self.barcodeScanner = barcodeScanner
        self.barcodeTypes = barcodeTypes
    }
    
    func scanBarcodes(in image: VisionImage, completion: @escaping (String?) -> Void) {
        self.barcodeScanner.process(image) { barcodes, error in
            
            if let err = error {
                print("error: \(err)")
            }
            
            guard let barcodes = barcodes else {
                completion(nil)
                return
            }
            
            let codes = barcodes.compactMap { $0.rawValue }
            
            codes.forEach { code in
                self.barcodeTypes.forEach { type in
                    if code.hasPrefix(type.prefix) {
                        completion(code)
                    }
                }
            }
        }
    }
}
