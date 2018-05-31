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
    init(statusItemView view: StatusItemView) {
        statusItemView = view
    }
    
    let interval: Double = 1
    
    var lastInBytes: Double = 0;
    var lastOutBytes: Double = 0;
    
    func start() {
        do {
            try SMCKit.open();
        } catch _ {
            
        }

        Thread(target: self, selector: #selector(startUpdateTimer), object: nil).start()
    }
    
    @objc func startUpdateTimer() {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateStat), userInfo: nil, repeats: true)
        RunLoop.current.run()
    }
    
    @objc func updateStat() {
        do {
            let coreTemp = try SMCKit.temperature(TemperatureSensors.CPU_0_PROXIMITY.code)
            let fanSpeed = try SMCKit.fanCurrentSpeed(0)
        
            var inBytes: CDouble = 0;
            var outBytes: CDouble = 0;
            if !readNetworkStat(&inBytes, &outBytes) {
                return
            }
            
            if lastInBytes > 0 && lastOutBytes > 0 {
                let upSpeed = (outBytes - lastOutBytes) / interval
                let downSpeed = (inBytes - lastInBytes) / interval
                statusItemView.setRateData(up: upSpeed, down: downSpeed, coreTemp: Int(coreTemp), fanSpeed: fanSpeed);
            }
            
            lastInBytes = inBytes;
            lastOutBytes = outBytes;
        } catch _ {
            
        }
    }
}
