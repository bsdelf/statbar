//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  Copyright © 2024 bsdelf. All rights reserved.

#pragma once
#include "NetworkSampleData.h"

void* NetworkMonitorCreate();
void NetworkMonitorDestroy(void* ptr);
struct NetworkSampleData NetworkMonitorSample(void* ptr);
