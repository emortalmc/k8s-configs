// @ts-check
// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar('none');
var DNS_POWERDNS = NewDnsProvider('powerdns');

/**
 * Production zone
 */

D("emc", REG_NONE, DnsProvider(DNS_POWERDNS),
    // Root info
    A("@", "100.64.209.7"),

    // Service CNAMEs
    CNAME("argo", "emc."),
    CNAME("metrics", "emc."),
    CNAME("linkerd", "emc."),
    CNAME("traefik", "emc.")
);

/**
 * Staging zone
 */

D("emc.staging", REG_NONE, DnsProvider(DNS_POWERDNS),
    // Root info
    A("@", "100.91.143.11"),

    CNAME("argo", "emc.staging."),
    CNAME("metrics", "emc.staging."),
    CNAME("linkerd", "emc.staging."),
    CNAME("traefik", "emc.staging.")
);
