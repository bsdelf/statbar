//
//  StatusItemView.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import AppKit
import Foundation

extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        guard toLength > self.count else { return self }
        let padding = String(repeating: withPad, count: toLength - self.count)
        return padding + self
    }
}

open class StatusItemView: NSControl {
    let fontSize: CGFloat = 9
    var mouseDown = false
    var statusItem: NSStatusItem

    var upRateStr = "- - KB/s"
    var downRateStr = "- - KB/s"
    var fanSpeedStr = "- -"
    var coreTempStr = "- -"
    
    init(statusItem aStatusItem: NSStatusItem, menu aMenu: NSMenu) {
        statusItem = aStatusItem
        super.init(frame: NSMakeRect(0, 0, statusItem.length, aMenu.menuBarHeight))
        menu = aMenu
        menu?.delegate = self
        SystemThemeChangeHelper.addRespond(target: self, selector: #selector(self.onSystemThemeChanged))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: mouseDown)
        let darkMode = SystemThemeChangeHelper.isCurrentDark()
        let fontColor = (darkMode || mouseDown) ? NSColor.white : NSColor.black
        let fontAttributes = [
            NSAttributedStringKey.font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: NSFont.Weight.regular),
            NSAttributedStringKey.foregroundColor: fontColor
        ] as [NSAttributedStringKey: Any]
        
        let rectSize = NSSize(width: 80, height: 20)
        
        let strs = [
            upRateStr + " ↗",
            downRateStr + " ↙",
            coreTempStr + " ℃",
            fanSpeedStr + " ♨",
        ]
        
        // 5 | 40 | 5 | 40 |
        
        var xoffset = bounds.width;
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
    
    open func updateMetrics(up: Double?, down: Double?, coreTemp: Int?, fanSpeed: Int?) {
        if let val = up {
            upRateStr = addBlank(str: formatRateData(val), toLength: 11)
        }
        if let val = down {
            downRateStr = addBlank(str: formatRateData(val), toLength: 11)
        }
        if let val = coreTemp {
            coreTempStr = addBlank(str: "\(val)", toLength: 4)
        }
        if let val = fanSpeed {
            fanSpeedStr = addBlank(str: val < 1 ? "0" : "\(val)", toLength: 4)
        }
        setNeedsDisplay()
    }
    
    func addBlank(str: String, toLength: Int) -> String {
        return str.leftPadding(toLength: toLength, withPad: " ")
    }
    
    func formatRateData(_ data:Double) -> String {
        let KB: Double = 1024
        let MB: Double = KB * 1024
        let GB: Double = MB * 1024
        let TB: Double = GB * 1024
        
        var result: Double
        var unit: String
        if data < KB / 100 {
            result = 0
            return "0.00 KB/s"
        } else if data < MB {
            result = data / KB
            unit = " KB/s"
        } else if data < GB {
            result = data / MB
            unit = " MB/s"
        } else if data < TB {
            result = data / GB
            unit = " GB/s"
        } else {
            result = 1023
            unit = " GB/s"
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
    
    @objc func onSystemThemeChanged(notification: NSNotification) {
        setNeedsDisplay()
    }
}

//action
extension StatusItemView: NSMenuDelegate{
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
