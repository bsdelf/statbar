//
//  MonitorTask.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation

open class SystemMonitor: NSObject {
    let statusItemView: StatusItemView
    let networkMonitor: UnsafeMutableRawPointer
    let interval: Double = 1
    var lastInBytes: Double = 0
    var lastOutBytes: Double = 0
    
    init(statusItemView view: StatusItemView) {
        statusItemView = view
        networkMonitor = UnsafeMutableRawPointer(NetworkMonitorCreate())
    }
    
    deinit {
        NetworkMonitorDestroy(networkMonitor);
    }
    
    func start() {
        do {
            try SMCKit.open();
        } catch _ {
            
        }

        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateStat), userInfo: nil, repeats: true)
    }
    
    @objc func updateStat() {
        let coreTemp = try? Int(SMCKit.temperature(TemperatureSensors.CPU_0_PROXIMITY.code))
        let fanSpeed = try? SMCKit.fanCurrentSpeed(0)

        var upSpeed: Double?
        var downSpeed: Double?
        let stats = NetworkMonitorStats(networkMonitor)
        if lastInBytes > 0 && lastOutBytes > 0 {
            upSpeed = (Double(stats.obytes) - lastOutBytes) / interval
            downSpeed = (Double(stats.ibytes) - lastInBytes) / interval
        }
        lastInBytes = Double(stats.ibytes);
        lastOutBytes = Double(stats.obytes);

        statusItemView.updateMetrics(up: upSpeed, down: downSpeed, coreTemp: coreTemp, fanSpeed: fanSpeed);
    }
}
