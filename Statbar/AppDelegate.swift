//
//  AppDelegate.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: StatbarController

    @MainActor
    override init() {
        controller = StatbarController();
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {

    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.controller.dismiss()
    }
}
