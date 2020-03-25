//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  Copyright © 2017 bsdelf. All rights reserved.

#include "NetworkStats.h"

void* NetworkMonitorCreate();
void NetworkMonitorDestroy(void* ptr);
struct NetworkStats NetworkMonitorStats(void* ptr);
