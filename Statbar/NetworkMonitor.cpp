//
//  NetworkMonitor.cpp
//  statbar
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
auto NetworkMonitor::Stats() -> NetworkStats {
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
        return {0, 0};
    }
    if (buf_.size() != buflen) {
        buf_.resize(buflen);
    }
    if (sysctl(name, namelen, buf_.data(), &buflen, nullptr, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return {0, 0};
    }
    
    // parse data
    uint32_t ibytes = 0;
    uint32_t obytes = 0;
    char* lim = buf_.data() + buflen;
    char* next = buf_.data();
    while (next < lim) {
        auto ifm = reinterpret_cast<struct if_msghdr*>(next);
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            auto if2m = reinterpret_cast<struct if_msghdr2*>(ifm);
            ibytes += if2m->ifm_data.ifi_ibytes;
            obytes += if2m->ifm_data.ifi_obytes;
        }
    }
    return {ibytes, obytes};
}
