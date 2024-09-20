//
//  StatbarView.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//

import AppKit
import Foundation

class StatbarView: NSView {
    let fontAttributes = [
        NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: 9, weight: NSFont.Weight.regular),
        NSAttributedString.Key.foregroundColor: NSColor.headerTextColor
    ]
    var upRateStr = formatSpeed(0).padStart(targetLength: 11)
    var downRateStr = formatSpeed(0).padStart(targetLength: 11)

    override func draw(_ dirtyRect: NSRect) {
        let rectSize = NSSize(width: 80, height: 20)

        let strs = [
            upRateStr + " ↗",
            downRateStr + " ↙",
//            coreTempStr + " ℃",
//            fanSpeedStr + " ♨",
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

    public func update(up: Double?, down: Double?, coreTemp: Int?, fanSpeed: Int?) {
        if let val = up {
            upRateStr = formatSpeed(val).padStart(targetLength: 11)
        }
        if let val = down {
            downRateStr = formatSpeed(val).padStart(targetLength: 11)
        }
//        if let val = coreTemp {
//            self.coreTempStr = String(val).padStart(targetLength: 4)
//        }
//        if let val = fanSpeed {
//            self.fanSpeedStr = String(max(val, 0)).padStart(targetLength: 4)
//        }
        setNeedsDisplay(frame)
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
