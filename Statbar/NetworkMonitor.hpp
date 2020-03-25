//
//  NetworkMonitor.hpp
//  statbar
//
//  Copyright © 2018年 bsdelf. All rights reserved.
//

#pragma once

#include <vector>
#include "NetworkStats.h"

class NetworkMonitor {
public:
    auto Stats() -> NetworkStats;
    
private:
    std::vector<char> buf_;
};
