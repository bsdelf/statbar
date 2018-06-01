//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  Copyright © 2017 bsdelf. All rights reserved.

#include <stdbool.h>
#include <inttypes.h>

void* CreateNetworkStat();
void DestroyNetworkStat(void* ptr);
bool NetworkStatUpdate(void* ptr);
double NetworkStatGetInBytes(void* ptr);
double NetworkStatGetOutBytes(void* ptr);
