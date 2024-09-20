//
//  NetworkMonitor.cpp
//  statusbar
//
//  Copyright © 2018年 bsdelf. All rights reserved.
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
auto NetworkMonitor::Sample() -> NetworkMonitorSampleData {
    const NetworkMonitorSampleData emptyResult {0,0};
    // read data
    int name[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    const u_int namelen = sizeof(name) / sizeof(name[0]);
    size_t buflen = 0;
    if (sysctl(name, namelen, nullptr, &buflen, nullptr, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return emptyResult;
    }
    if (buffer_.size() != buflen) {
        buffer_.resize(buflen);
    }
    if (sysctl(name, namelen, buffer_.data(), &buflen, nullptr, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return emptyResult;
    }
    
    // parse data
    uint64_t inBytes = 0;
    uint64_t outBytes = 0;
    char* lim = buffer_.data() + buflen;
    char* next = buffer_.data();
    while (next < lim) {
        auto ifm = reinterpret_cast<struct if_msghdr*>(next);
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            auto if2m = reinterpret_cast<struct if_msghdr2*>(ifm);
            inBytes += if2m->ifm_data.ifi_ibytes;
            outBytes += if2m->ifm_data.ifi_obytes;
        }
    }
    return {inBytes, outBytes};
}
