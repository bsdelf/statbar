//
//  StatbarController.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import AppKit
import Foundation

func buildMenu(_ targets: inout[NSTarget]) -> NSMenu {
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
            NSWorkspace.shared.open(URL(string: "https://github.com/bsdelf/statusbar")!)
            break
        default:
            break
        }
    }
    aboutMenu.title = NSLocalizedString("About", comment: "")
    aboutMenu.target = aboutMenuTarget
    aboutMenu.action = #selector(aboutMenuTarget.action)
    targets.append(aboutMenuTarget)

    let quitMenu = NSMenuItem()
    let quitMenuTarget = NSTarget{
        NSApp.terminate(nil)
    }
    quitMenu.title = NSLocalizedString("Quit", comment: "")
    quitMenu.keyEquivalent = "q"
    quitMenu.target = quitMenuTarget
    quitMenu.action = #selector(quitMenuTarget.action)
    targets.append(quitMenuTarget)

    let menu = NSMenu()
    menu.addItem(NSMenuItem.separator())
    menu.addItem(aboutMenu)
    menu.addItem(quitMenu)
    return menu
}

public class StatbarController {
    var statusItem: NSStatusItem
    var menu: NSMenu
    var view = StatbarView()
    var targets = Array<NSTarget>()
    var systemMonitor = SystemMonitor()
    var updateTimer: Timer?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.isVisible = true
        statusItem.length = 72
        menu = buildMenu(&targets)

        guard let button = statusItem.button else {return}
        view.frame = button.bounds
        button.wantsLayer = true
        button.addSubview(view)
        button.target = self
        button.action = #selector(itemClicked)
        button.sendAction(on: [.leftMouseDown])

        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.update()
        })
    }

    func dismiss() {
        updateTimer?.invalidate()
        NSStatusBar.system.removeStatusItem(self.statusItem)
    }

    func update() {
        let sampleData = systemMonitor.sapmple()
        view
            .update(
                up: sampleData.outBytesPerSecond,
                down: sampleData.inBytesPerSecond,
                coreTemp: nil,
                fanSpeed: nil
            )
    }

    @objc func itemClicked(){
        switch NSApp.currentEvent?.type {
        case .leftMouseDown:
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil

        default: break
        }
    }
}
