//
//  AppDelegate.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: StatbarController

    override init() {
        controller = StatbarController();
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {

    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.controller.dismiss()
    }
}
