//
//  SystemMonitor.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation

struct SystemMonitorSampleData {
    var inBytesPerSecond: Double?
    var outBytesPerSecond: Double?
}

open class SystemMonitor {
    var networkMonitor: UnsafeMutableRawPointer? = nil
    var sampledAt: TimeInterval = -1;
    var sampledInBytes: Double = -1
    var sampledOutBytes: Double = -1

    init() {
        self.networkMonitor = UnsafeMutableRawPointer(NetworkMonitorCreate())
    }

    deinit {
        NetworkMonitorDestroy(self.networkMonitor)
        self.networkMonitor = nil
    }

    func sapmple() -> SystemMonitorSampleData {
        var result = SystemMonitorSampleData()

        let sampleData = NetworkMonitorSample(self.networkMonitor)
        let nextInbytes = Double(sampleData.inBytes)
        let nextOutbytes = Double(sampleData.outBytes)
        let nextSampledAt = Date().timeIntervalSince1970

        if sampledAt >= 0 {
            let elapsedSeconds = nextSampledAt - sampledAt
            result.inBytesPerSecond = (nextInbytes - sampledInBytes) / elapsedSeconds
            result.outBytesPerSecond = (nextOutbytes - sampledOutBytes) / elapsedSeconds
        }
        sampledAt = nextSampledAt
        sampledInBytes = nextInbytes
        sampledOutBytes = nextOutbytes

        return result
    }
}
