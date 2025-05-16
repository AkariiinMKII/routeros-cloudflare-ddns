# This script sets up variables for CloudFlare DDNS updater in RouterOS script.

# Requires policy to be set to "read, write, policy, test" for the script to work.

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Setup Cloudflare API credentials
# Replace with your own Cloudflare zone ID and API token
:global cfZoneId "_ZONE_ID_";
:global cfDnsApiToken "_API_TOKEN_";

# Setup IPv6 WAN interface
# Replace with your own IPv6 WAN interface name
:local Wan6Interface "_INTERFACE_"

# Setup DNS record updater function
:global UpdateDnsRecord [:parse [/system script get "ddns-updater" source]]

# Auto update IPv6 GUA prefix
:global WanIP6Prefix

:if ([/ipv6 dhcp-client get [find interface=$Wan6Interface] status] = "bound") do={
    :local getWanIP6Prefix [/ipv6 dhcp-client get [find interface=$Wan6Interface status=bound] prefix];
    :set getWanIP6Prefix [:pick $getWanIP6Prefix 0 [:find $getWanIP6Prefix "::"]];
    :if ($getWanIP6Prefix != $WanIP6Prefix) do={
        :set WanIP6Prefix $getWanIP6Prefix;
        :log info ("[ddns-initializer] Detected new IPv6 GUA prefix: $WanIP6Prefix");
        /system script run "ddns-checker"
    }
} else={
    :log error ("[ddns-initializer] Failed to get IPv6 GUA prefix");
}
