//
//  Statbar-Bridging-Body.c
//  Statbar
//
//  Created by bsdelf on 2020/3/25.
//  Copyright © 2024 bsdelf. All rights reserved.
//

#include "NetworkMonitor.hpp"

extern "C" {
    void* NetworkMonitorCreate() {
        return new NetworkMonitor();
    }
    
    void NetworkMonitorDestroy(void* ptr) {
        delete static_cast<NetworkMonitor*>(ptr);
    }
    
    struct NetworkMonitorSampleData NetworkMonitorSample(void* ptr) {
        auto self = static_cast<NetworkMonitor*>(ptr);
        return self->Sample();
    }
}
