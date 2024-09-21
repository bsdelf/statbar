//
//  SystemMonitor.swift
//  Statbar
//
//  Copyright © 2024 bsdelf. All rights reserved.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import Foundation

struct NetworkStat {
    var inBytesPerSecond: Double
    var outBytesPerSecond: Double
}

final class SystemMonitor {
    var networkMonitor: UnsafeMutableRawPointer? = nil
    var sampledAt: TimeInterval = -1;
    var sampledInBytes: Double = -1
    var sampledOutBytes: Double = -1
    var networkStats = Ring<NetworkStat>(capacity: 2)

    init() {
        self.networkMonitor = UnsafeMutableRawPointer(NetworkMonitorCreate())
    }

    deinit {
        NetworkMonitorDestroy(self.networkMonitor)
        self.networkMonitor = nil
    }

    func update() -> NetworkStat? {
        let sampleData = NetworkMonitorSample(self.networkMonitor)
        let nextInbytes = Double(sampleData.in_bytes)
        let nextOutbytes = Double(sampleData.out_bytes)
        let nextSampledAt = Date().timeIntervalSince1970

        if sampledAt >= 0 {
            let elapsedSeconds = nextSampledAt - sampledAt
            let inBytesPerSecond = (nextInbytes - sampledInBytes) / elapsedSeconds
            let outBytesPerSecond = (nextOutbytes - sampledOutBytes) / elapsedSeconds
            let networkStat = NetworkStat(
                inBytesPerSecond: inBytesPerSecond,
                outBytesPerSecond: outBytesPerSecond
            )
            networkStats.push(item: networkStat)
        }
        sampledAt = nextSampledAt
        sampledInBytes = nextInbytes
        sampledOutBytes = nextOutbytes

        if networkStats.items.isEmpty {
            return nil
        }

        // calculate average
        var inBytesPerSecond: Double = 0
        var outBytesPerSecond: Double = 0
        for item in networkStats.items {
            inBytesPerSecond += item.inBytesPerSecond
            outBytesPerSecond += item.outBytesPerSecond
        }
        inBytesPerSecond /= Double(networkStats.items.count)
        outBytesPerSecond /= Double(networkStats.items.count)
        return NetworkStat(inBytesPerSecond: inBytesPerSecond, outBytesPerSecond: outBytesPerSecond)
    }
}
