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
    let networkstat: UnsafeMutableRawPointer
    let interval: Double = 1
    var lastInBytes: Double = 0
    var lastOutBytes: Double = 0
    
    init(statusItemView view: StatusItemView) {
        statusItemView = view
        networkstat = UnsafeMutableRawPointer(CreateNetworkStat())
    }
    
    deinit {
        DestroyNetworkStat(networkstat);
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
        if NetworkStatUpdate(networkstat) {
            let inBytes = NetworkStatGetInBytes(networkstat);
            let outBytes = NetworkStatGetOutBytes(networkstat);
            if lastInBytes > 0 && lastOutBytes > 0 {
                upSpeed = (outBytes - lastOutBytes) / interval
                downSpeed = (inBytes - lastInBytes) / interval
            }
            lastInBytes = inBytes;
            lastOutBytes = outBytes;
        }

        statusItemView.updateMetrics(up: upSpeed, down: downSpeed, coreTemp: coreTemp, fanSpeed: fanSpeed);
    }
}
