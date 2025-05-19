# This script updates the DNS record on Cloudflare using the Cloudflare API.

# This script does not require any permissions as it is only used for function importing.

# Name of this script should exactly be "ddns-update-dns-record"

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Import global variables
:global cfZoneId;
:global cfDnsApiToken;

# Resolve local variables
:local DomainName ($Profile->"DomainName");
:local DomainId ($Profile->"DomainId");
:local WanIP6 ($Profile->"WanIP6");
:local RecordType ($Profile->"RecordType");
:local RecordTTL ($Profile->"RecordTTL");
:local Proxied ($Profile->"Proxied");

# Generate web request parameters
:local url    "https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$DomainId";
:local header "Authorization: Bearer $cfDnsApiToken, content-type: application/json";
:local data   "{\"type\":\"$RecordType\",\"name\":\"$DomainName\",\"content\":\"$WanIP6\",\"ttl\":$RecordTTL,\"proxied\":$Proxied}";

# Update DNS record
:log info ("[ddns-updater] Updating \"$DomainName\" DNS record to $WanIP6 ...");
/tool fetch \
    http-method=put \
    mode=https \
    http-header-field=$header \
    http-data=$data \
    url=$url \
    as-value \
    output=user;

# Check update result
:local FetchDnsRecord [:parse [/system script get "ddns-fetch-dns-record" source]];
:local NewResolvedIP [$FetchDnsRecord Profile=$Profile];
:if ($NewResolvedIP = $WanIP6) do={
    :log info ("[ddns-updater] Successfully updated \"$DomainName\" DNS record.");
} else={
    :log error ("[ddns-updater] Failed to update \"$DomainName\" DNS record.");
}
