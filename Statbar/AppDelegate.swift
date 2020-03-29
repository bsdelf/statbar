//
//  AppDelegate.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Cocoa

final class NSTarget: NSObject {
    private let callback: () -> ()

    init(callback: @escaping () -> ()) {
        self.callback = callback
        super.init()
    }

    @objc func action() {
        self.callback()
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var monitor: SystemMonitor? = nil
    var targets = Array<NSTarget>()
    let statusItem: NSStatusItem
    let statusItemView: StatusItemView

    override init() {
        let autoLaunchMenu = NSMenuItem()
        let autoLaunchMenuTarget = NSTarget{
            AutoLaunchHelper.toggleLoginStart()
            autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLoginStartEnabled() ? 1 : 0)
        }
        autoLaunchMenu.title = NSLocalizedString("Start at login", comment: "")
        autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLoginStartEnabled() ? 1 : 0)
        autoLaunchMenu.target = autoLaunchMenuTarget
        autoLaunchMenu.action = #selector(autoLaunchMenuTarget.action)
        self.targets.append(autoLaunchMenuTarget)

        let aboutMenu = NSMenuItem()
        let aboutMenuTarget = NSTarget{
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("About title", comment:"")
            alert.addButton(withTitle: "Github")
            alert.addButton(withTitle: NSLocalizedString("Close", comment:""))
            alert.informativeText = NSLocalizedString("About content", comment: "")
            let result = alert.runModal()
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                NSWorkspace.shared.open(URL(string: "https://github.com/bsdelf/statbar")!)
                break
            default:
                break
            }
        }
        aboutMenu.title = NSLocalizedString("About", comment: "")
        aboutMenu.target = aboutMenuTarget
        aboutMenu.action = #selector(aboutMenuTarget.action)
        self.targets.append(aboutMenuTarget)

        let quitMenu = NSMenuItem()
        let quitMenuTarget = NSTarget{
            NSApp.terminate(nil)
        }
        quitMenu.title = NSLocalizedString("Quit", comment: "")
        quitMenu.keyEquivalent = "q"
        quitMenu.target = quitMenuTarget
        quitMenu.action = #selector(quitMenuTarget.action)
        self.targets.append(quitMenuTarget)

        let menu = NSMenu()
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(aboutMenu)
        menu.addItem(quitMenu)
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: 120)
        self.statusItemView = StatusItemView(statusItem: statusItem, menu: menu)
        self.statusItem.view = self.statusItemView
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.monitor = SystemMonitor(interval: 1)
        self.monitor?.statusItemView = self.statusItemView
        self.monitor?.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.monitor?.stop()
    }
}
