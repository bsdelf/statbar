//
//  NetworkStat.cpp
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
#include "NetworkStat.hpp"

auto NetworkStat::Update() -> bool
{
    int mib[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    
    // prepare buffer
    size_t len = 0;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return false;
    }
    if (buf_.size() != len) {
        buf_.resize(len);
    }
    
    // read data
    if (sysctl(mib, 6, buf_.data(), &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return false;
    }
    
    // parse data
    char *lim = buf_.data() + len;
    char *next = NULL;
    ibytes_ = 0;
    obytes_ = 0;
    for (next = buf_.data(); next < lim; ) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
            ibytes_ += if2m->ifm_data.ifi_ibytes;
            obytes_ += if2m->ifm_data.ifi_obytes;
        }
    }
    return true;
}

extern "C" {

    void* CreateNetworkStat() {
        return new NetworkStat();
    }
    
    void DestroyNetworkStat(void* ptr) {
        delete static_cast<NetworkStat*>(ptr);
    }
    
    bool NetworkStatUpdate(void* ptr) {
        auto self = static_cast<NetworkStat*>(ptr);
        return self->Update();
    }
    
    double NetworkStatGetInBytes(void* ptr) {
        auto self = static_cast<NetworkStat*>(ptr);
        return self->GetInBytes();
    }

    double NetworkStatGetOutBytes(void* ptr) {
        auto self = static_cast<NetworkStat*>(ptr);
        return self->GetOutBytes();
    }
    
    double HelloWorld() {
        return 100;
    }
}
