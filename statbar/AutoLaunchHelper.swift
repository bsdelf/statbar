//
//  AutoLaunchHelper.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation
import ServiceManagement

open class AutoLaunchHelper {
    static func isLoginStartEnabled() -> Bool {
        return UserDefaults.standard.string(forKey: "appLoginStart") == "true"
    }
    
    static func toggleLoginStart() {
        let identifier = "com.bsdelf.StatbarHelper" // Bundle.main.bundleIdentifier!
        let toggled = !isLoginStartEnabled()
        let ok = SMLoginItemSetEnabled(identifier as CFString, toggled)
        if (ok) {
            UserDefaults.standard.set(String(toggled), forKey: "appLoginStart")
        } else {
            print("Failed to toggle login start", identifier, toggled);
        }
    }
}
