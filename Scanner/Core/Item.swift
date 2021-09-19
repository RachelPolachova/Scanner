//
//  Item.swift
//  Item
//
//  Created by Ráchel Polachová on 07/09/2021.
//

import Foundation

struct Device {
    let type: DeviceType
    var serialNo: String?
    
    var state: State { self.serialNo != nil ? .valid : .invalid }
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

enum State {
    case valid, invalid
}

enum DeviceType: String, CaseIterable {
    case watch, iPhone, iPad, keyboard, mouse, trackpad
    
    var iconName: String {
        switch self {
        case .watch:
            return "stopwatch"
        case .iPhone:
            return "phone"
        case .iPad:
            return "rectangle.portrait"
        case .keyboard:
            return "keyboard"
        case .mouse:
            return "oval.portrait"
        case .trackpad:
            return "rectangle"
        }
    }
}

struct Item {
    let name: String
    let devices: [Device]
}
