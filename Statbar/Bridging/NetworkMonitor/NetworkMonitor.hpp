//
//  NetworkMonitor.hpp
//  statusbar
//
//  Copyright © 2018年 bsdelf. All rights reserved.
//

#pragma once

#include <vector>
#include "NetworkMonitorSampleData.h"

class NetworkMonitor {
public:
    auto Sample() -> NetworkMonitorSampleData;

private:
    std::vector<char> buffer_;
};
