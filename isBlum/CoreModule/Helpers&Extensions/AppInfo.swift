//
//  AppInfo.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import UIKit

struct AppInfo {
    
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    }
}

struct DeviceInfo {
    
    /// Returns the exact device model (e.g. "iPhone 15 Pro")
    static var modelName: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return mapToDevice(identifier: identifier)
    }
    
    private static func mapToDevice(identifier: String) -> String {
        
        switch identifier {
            
        // iPhone 15
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
            
        // iPhone 14
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
            
        // iPhone 13
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
            
        // Simulator
        case "x86_64", "arm64":
            return "Simulator"
            
        default:
            return identifier
        }
    }
}
