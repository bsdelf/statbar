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
    static let KB:Double = 1024
    static let MB:Double = KB*1024
    static let GB:Double = MB*1024
    static let TB:Double = GB*1024
    
    var fontSize:CGFloat = 9
    var fontColor = NSColor.black
    var darkMode = false
    var mouseDown = false
    var statusItem:NSStatusItem
    
    var upRate = "- - KB/s"
    var downRate = "- - KB/s"
    
    var fanSpeedStr = "- -"
    var coreTempStr = "- -"
    
    init(statusItem aStatusItem: NSStatusItem, menu aMenu: NSMenu) {
        statusItem = aStatusItem
        super.init(frame: NSMakeRect(0, 0, statusItem.length, 30))
        menu = aMenu
        menu?.delegate = self
        
        darkMode = SystemThemeChangeHelper.isCurrentDark()
        
        SystemThemeChangeHelper.addRespond(target: self, selector: #selector(changeMode))
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: mouseDown)
        
        
        fontColor = (darkMode||mouseDown) ? NSColor.white : NSColor.black
        let fontAttributes = [
            NSAttributedStringKey.font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: NSFont.Weight.regular),
            NSAttributedStringKey.foregroundColor: fontColor
            ] as [NSAttributedStringKey : Any]
        
        let fanSpeedString = NSAttributedString(string: fanSpeedStr+" ♨", attributes: fontAttributes)
        let fanSpeedRect = fanSpeedString.boundingRect(with: NSSize(width: 100, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        fanSpeedString.draw(at: NSMakePoint(bounds.width - fanSpeedRect.width - 5, 0))
        
        let coreTempString = NSAttributedString(string: coreTempStr+" ℃", attributes: fontAttributes)
        let coreTempRect = coreTempString.boundingRect(with: NSSize(width: 100, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        coreTempString.draw(at: NSMakePoint(bounds.width - coreTempRect.width - 5, 10))
        

        let upRateString = NSAttributedString(string: upRate + " ↗", attributes: fontAttributes)
        let upRateRect = upRateString.boundingRect(with: NSSize(width: 100, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        //upRateString.draw(at: NSMakePoint(bounds.width - upRateRect.width - 40 - 5, 0))
        upRateString.draw(at: NSMakePoint(bounds.width - upRateRect.width - 40 - 5, 10))
        
        let downRateString = NSAttributedString(string: downRate + " ↙", attributes: fontAttributes)
        let downRateRect = downRateString.boundingRect(with: NSSize(width: 100, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        //downRateString.draw(at: NSMakePoint(bounds.width - downRateRect.width - 40 - 5, 10))
        downRateString.draw(at: NSMakePoint(bounds.width - downRateRect.width - 40 - 5, 0))
    }
    
    open func setRateData(up: Double, down: Double, coreTemp: Int, fanSpeed: Int) {
        let _upRate = formatRateData(up)
        let _downRate = formatRateData(down)
        upRate = addBlank(str: _upRate, toLength: 11)
        downRate = addBlank(str: _downRate, toLength: 11)
            
        coreTempStr = addBlank(str: "\(coreTemp)", toLength: 4)
        fanSpeedStr = addBlank(str: fanSpeed == 0 ? "0" : "\(fanSpeed)", toLength: 4)
            
        setNeedsDisplay()
    }
    
    func addBlank(str: String, toLength: Int) -> String {
        return str.leftPadding(toLength: toLength, withPad: " ")
    }
    
    func formatRateData(_ data:Double) -> String {
        var result:Double
        var unit: String
        
        if data < StatusItemView.KB/100 {
            result = 0
            return "0.00 KB/s"
        }
            
        else if data < StatusItemView.MB{
            result = data/StatusItemView.KB
            unit = " KB/s"
        }
            
        else if data < StatusItemView.GB {
            result = data/StatusItemView.MB
            unit = " MB/s"
        }
            
        else if data < StatusItemView.TB {
            result = data/StatusItemView.GB
            unit = " GB/s"
        }
            
        else {
            result = 1023
            unit = " GB/s"
        }
        
        if result < 100 {
            return String(format: "%0.2f", result) + unit
        }
        else if result < 999 {
            return String(format: "%0.1f", result) + unit
        }
        else {
            return String(format: "%0.0f", result) + unit
        }
    }
    
    @objc func changeMode() {
        darkMode = SystemThemeChangeHelper.isCurrentDark()
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
