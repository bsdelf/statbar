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

bool readNetIO(double* ibytes, double* obytes) {
    assert(ibytes);
    assert(obytes);

    int mib[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };

    size_t len = 0;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return false;
    }

    char *buf = (char *)malloc(len);

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        return false;
    }

    char *lim = buf + len;
    char *next = NULL;
    *ibytes = 0;
    *obytes = 0;
    for (next = buf; next < lim; ) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
            *ibytes += if2m->ifm_data.ifi_ibytes;
            *obytes += if2m->ifm_data.ifi_obytes;
        }
    }

    free(buf);

    return true;
}

