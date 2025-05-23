# This script sets up variables for CloudFlare DDNS updater in RouterOS script.

# Requires policy to be set to "read, write, policy, test" for the script to work.

# Name of this script should exactly be "ddns-initialize-variables"

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Setup record profiles
# Each profile is a separate DNS record, and requires a separate script to update.
# Replace with your own data according to your needs.
:global DdnsProfile1;
:set ($DdnsProfile1->"DomainName") "www.example.com";
:set ($DdnsProfile1->"WanIP6Tail") "::1";
:set ($DdnsProfile1->"RecordType") "AAAA";
:set ($DdnsProfile1->"RecordTTL") 300;
:set ($DdnsProfile1->"Proxied") false;

# :global DdnsProfile2;
# :set ($DdnsProfile2->"DomainName") "www2.example.com";
# :set ($DdnsProfile2->"WanIP6Tail") "::2";
# :set ($DdnsProfile2->"RecordType") "AAAA";
# :set ($DdnsProfile2->"RecordTTL") 300;
# :set ($DdnsProfile2->"Proxied") false;

# Setup Cloudflare API credentials
# Replace with your own Cloudflare zone ID and API token.
:global cfZoneId "_ZONE_ID_";
:global cfDnsApiToken "_API_TOKEN_";

# Setup IPv6 WAN interface
# Replace with your own IPv6 WAN interface name.
:local Wan6Interface "_INTERFACE_";

# Auto update IPv6 GUA prefix
:if ([/ipv6 dhcp-client get [find interface=$Wan6Interface] status] = "bound") do={
    :local NewWanIP6Prefix [/ipv6 dhcp-client get [find interface=$Wan6Interface status=bound] prefix];
    :set NewWanIP6Prefix [:pick $NewWanIP6Prefix 0 [:find $NewWanIP6Prefix "::"]];
    :global WanIP6Prefix;
    :global DdnsLastRunFailed;
    :if ((($NewWanIP6Prefix != $WanIP6Prefix)||($DdnsLastRunFailed = true))&&([:len $NewWanIP6Prefix] > 0)) do={
        :log info ("[ddns-initializer] Detected new IPv6 GUA prefix: $NewWanIP6Prefix");
        :set DdnsLastRunFailed false;
        :set WanIP6Prefix $NewWanIP6Prefix;
        /system script run "ddns-check-profile1";
        # /system script run "ddns-check-profile2";
    }
}
