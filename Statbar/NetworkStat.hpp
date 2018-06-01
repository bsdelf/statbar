//
//  NetworkStat.hpp
//  statbar
//
//  Copyright © 2018年 bsdelf. All rights reserved.
//

#pragma once

#include <vector>

class NetworkStat {
public:
    NetworkStat() = default;
    auto Update() -> bool;
    auto GetInBytes() const -> double { return ibytes_; }
    auto GetOutBytes() const -> double { return obytes_; }
private:
    double ibytes_ = 0;
    double obytes_ = 0;
    std::vector<char> buf_;
};
