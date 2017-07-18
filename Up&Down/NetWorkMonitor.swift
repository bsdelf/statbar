//
//  MonitorTask.swift
//  Up&Down
//
//  Created by 郭佳哲 on 6/3/16.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation

open class NetWorkMonitor: NSObject {
    let statusItemView: StatusItemView
    init(statusItemView view: StatusItemView) {
        statusItemView = view
    }
    
    let interval: Double = 1
    
    var _ibytes: Double = 0;
    var _obytes: Double = 0;
    
    func start() {
        Thread(target: self, selector: #selector(startUpdateTimer), object: nil).start()
    }
    
    func startUpdateTimer() {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateNetWorkData), userInfo: nil, repeats: true)
        RunLoop.current.run()
    }
    
    func updateNetWorkData() {
        var ibytes: CDouble = 0;
        var obytes: CDouble = 0;
        let ok = readNetIO(&ibytes, &obytes);
        if (ok) {
            if (_ibytes > 0 && _obytes > 0) {
                statusItemView.setRateData(up: obytes - _obytes, down: ibytes - _ibytes);
            }
            _ibytes = ibytes;
            _obytes = obytes;
        }
    }
}
