//
//  MonitorTask.swift
//  Statbar
//
//  Copyright © 2017 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation

open class SystemMonitor: NSObject {
    let interval: TimeInterval
    var lastInBytes: Double = 0
    var lastOutBytes: Double = 0
    var networkMonitor: UnsafeMutableRawPointer?
    var timer: Timer? = nil
    var statusItemView: StatusItemView? = nil

    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func start() {
        try? SMCKit.open();
        self.lastInBytes = 0
        self.lastOutBytes = 0
        self.networkMonitor = UnsafeMutableRawPointer(NetworkMonitorCreate())
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.updateStats), userInfo: nil, repeats: true)
    }
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        NetworkMonitorDestroy(self.networkMonitor);
        _ = SMCKit.close();
    }
    
    @objc func updateStats() {
        let coreTemp = try? Int(SMCKit.temperature(TemperatureSensors.CPU_0_PROXIMITY.code))
        let fanSpeed = try? SMCKit.fanCurrentSpeed(0)
        
        var upSpeed: Double?
        var downSpeed: Double?
        let stats = NetworkMonitorStats(self.networkMonitor)
        if lastInBytes > 0 && lastOutBytes > 0 {
            upSpeed = (Double(stats.obytes) - self.lastOutBytes) / self.interval
            downSpeed = (Double(stats.ibytes) - self.lastInBytes) / self.interval
        }
        self.lastInBytes = Double(stats.ibytes);
        self.lastOutBytes = Double(stats.obytes);

        self.statusItemView?.updateMetrics(up: upSpeed, down: downSpeed, coreTemp: coreTemp, fanSpeed: fanSpeed);
    }
}
