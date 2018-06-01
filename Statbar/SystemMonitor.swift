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
        do {
            let coreTemp = try SMCKit.temperature(TemperatureSensors.CPU_0_PROXIMITY.code)
            let fanSpeed = try SMCKit.fanCurrentSpeed(0)
        
            if !NetworkStatUpdate(networkstat) {
                return;
            }
            let inBytes = NetworkStatGetInBytes(networkstat);
            let outBytes = NetworkStatGetOutBytes(networkstat);
            if lastInBytes > 0 && lastOutBytes > 0 {
                let upSpeed = (outBytes - lastOutBytes) / interval
                let downSpeed = (inBytes - lastInBytes) / interval
                statusItemView.updateMetrics(up: upSpeed, down: downSpeed, coreTemp: Int(coreTemp), fanSpeed: fanSpeed);
            }
            lastInBytes = inBytes;
            lastOutBytes = outBytes;
        } catch _ {
            
        }
    }
}
