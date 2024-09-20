//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  Copyright © 2024 bsdelf. All rights reserved.

#include "NetworkMonitorSampleData.h"

void* NetworkMonitorCreate();
void NetworkMonitorDestroy(void* ptr);
struct NetworkMonitorSampleData NetworkMonitorSample(void* ptr);
