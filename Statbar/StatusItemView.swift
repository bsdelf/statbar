//
//  StatusItemView.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import AppKit
import Foundation

public class StatusItemView: NSControl {
    let fontSize: CGFloat = 9
    var mouseDown = false
    var statusItem: NSStatusItem

    var upRateStr = "- - KB/s"
    var downRateStr = "- - KB/s"
//    var fanSpeedStr = "- -"
//    var coreTempStr = "- -"
    
    init(statusItem: NSStatusItem, menu: NSMenu) {
        self.statusItem = statusItem
        super.init(frame: NSMakeRect(0, 0, statusItem.length, menu.menuBarHeight))
        self.menu = menu
        self.menu?.delegate = self
        SystemThemeChangeHelper.addRespond(target: self, selector: #selector(self.onSystemThemeChanged))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        self.statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: mouseDown)
        let darkMode = SystemThemeChangeHelper.isCurrentDark()
        let fontColor = (darkMode || mouseDown) ? NSColor.white : NSColor.black
        let fontAttributes = [
            NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: NSFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: fontColor
        ] as [NSAttributedString.Key: Any]
        
        let rectSize = NSSize(width: 80, height: 20)
        
        let strs = [
            self.upRateStr + " ↗",
            self.downRateStr + " ↙",
//            self.coreTempStr + " ℃",
//            self.fanSpeedStr + " ♨",
        ]
        
        // 5 | 40 | 5 | 40 |
        
        var xoffset = self.bounds.width;
        outerLoop:
        for col in (0 ..< ((strs.count + 1) / 2)).reversed() {
            var yoffset = CGFloat(0);
            for row in (0 ..< 2).reversed() {
                let i = col * 2 + row - strs.count & 1
                if i < 0 {
                    break outerLoop
                }
                let nsStr = NSAttributedString(string: strs[i], attributes: fontAttributes)
                let rect = nsStr.boundingRect(with: rectSize, options: NSString.DrawingOptions.usesLineFragmentOrigin)
                nsStr.draw(at: NSMakePoint(xoffset - rect.width - 5, yoffset))
                yoffset += 10;
            }
            xoffset -= 40;
        }
    }
    
    public func updateMetrics(up: Double?, down: Double?, coreTemp: Int?, fanSpeed: Int?) {
        if let val = up {
            self.upRateStr = formatSpeed(val).padStart(targetLength: 11)
        }
        if let val = down {
            self.downRateStr = formatSpeed(val).padStart(targetLength: 11)
        }
//        if let val = coreTemp {
//            self.coreTempStr = String(val).padStart(targetLength: 4)
//        }
//        if let val = fanSpeed {
//            self.fanSpeedStr = String(max(val, 0)).padStart(targetLength: 4)
//        }
        self.setNeedsDisplay()
    }
    
    @objc func onSystemThemeChanged(notification: NSNotification) {
        self.setNeedsDisplay()
    }
}

// actions
extension StatusItemView: NSMenuDelegate {
    open override func mouseDown(with theEvent: NSEvent) {
        statusItem.popUpMenu(menu!)
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        mouseDown = true
        setNeedsDisplay()
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        mouseDown = false
        setNeedsDisplay()
    }
}

func formatSpeed(_ val: Double) -> String {
    let KB: Double = 1024
    let MB: Double = KB * 1024
    let GB: Double = MB * 1024
    let TB: Double = GB * 1024

    var result: Double
    var unit: String
    if val < KB / 100 {
        result = 0
        return "0.00 KB/s"
    } else if val < MB {
        result = val / KB
        unit = " KB/s"
    } else if val < GB {
        result = val / MB
        unit = " MB/s"
    } else if val < TB {
        result = val / GB
        unit = " GB/s"
    } else {
        result = val / TB
        unit = " TB/s"
    }

    var format: String
    if result < 100 {
        format = "%0.2f"
    } else if result < 999 {
        format = "%0.1f"
    } else {
        format = "%0.0f"
    }

    return String(format: format, result) + unit
}
