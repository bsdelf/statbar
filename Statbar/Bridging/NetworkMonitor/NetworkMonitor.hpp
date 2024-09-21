//
//  NetworkMonitor.hpp
//  statbar
//
//  Copyright © 2024年 bsdelf. All rights reserved.
//

#pragma once

#include <vector>
#include <inttypes.h>

#include "NetworkSampleData.h"

class NetworkMonitor {
public:
    auto Sample() -> NetworkSampleData;

private:
    std::vector<uint8_t> buffer_;
};
