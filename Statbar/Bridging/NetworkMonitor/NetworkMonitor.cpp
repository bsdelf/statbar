//
//  NetworkMonitor.cpp
//  statbar
//
//  Copyright © 2024年 bsdelf. All rights reserved.
//

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <sys/sysctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <net/route.h>
#include "NetworkMonitor.hpp"

// Reference:
// https://opensource.apple.com/source/top/top-67/libtop.c
auto NetworkMonitor::Sample() -> NetworkSampleData {
    const NetworkSampleData empty_result {0,0};
    // read data
    int name[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    const u_int name_size = sizeof(name) / sizeof(name[0]);
    size_t buffer_size = 0;
    if (sysctl(name, name_size, nullptr, &buffer_size, nullptr, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return empty_result;
    }
    if (buffer_.size() != buffer_size) {
        buffer_.resize(buffer_size);
    }
    if (sysctl(name, name_size, buffer_.data(), &buffer_size, nullptr, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return empty_result;
    }
    
    // parse data
    uint64_t in_bytes = 0;
    uint64_t out_bytes = 0;
    uint8_t* limit = buffer_.data() + buffer_size;
    uint8_t* next = buffer_.data();
    while (next < limit) {
        auto ifm = reinterpret_cast<struct if_msghdr*>(next);
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            auto if2m = reinterpret_cast<struct if_msghdr2*>(ifm);
            in_bytes += if2m->ifm_data.ifi_ibytes;
            out_bytes += if2m->ifm_data.ifi_obytes;
        }
    }
    return {in_bytes, out_bytes};
}
