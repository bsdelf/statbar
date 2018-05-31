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
    
    var _ibytes: Double = 0;
    var _obytes: Double = 0;
    
    func start() {
        do {
            try SMCKit.open();
        } catch _ {
            
        }

        Thread(target: self, selector: #selector(startUpdateTimer), object: nil).start()
    }
    
    @objc func startUpdateTimer() {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateNetworkStat), userInfo: nil, repeats: true)
        RunLoop.current.run()
    }
    
    @objc func updateNetworkStat() {
        do {
            let coreTemp = try SMCKit.temperature(TemperatureSensors.CPU_0_PROXIMITY.code)
            let fanSpeed = try SMCKit.fanCurrentSpeed(0)
        
        
            var ibytes: CDouble = 0;
            var obytes: CDouble = 0;
            let ok = readNetIO(&ibytes, &obytes);
            if (ok) {
                if (_ibytes > 0 && _obytes > 0) {
                    statusItemView.setRateData(up: obytes - _obytes, down: ibytes - _ibytes, coreTemp: Int(coreTemp), fanSpeed: fanSpeed);
                }
                _ibytes = ibytes;
                _obytes = obytes;
            }
        } catch _ {
            
        }
    }
}
