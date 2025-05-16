# This script updates the DNS record on Cloudflare using the Cloudflare API.

# Requires policy to be set to "read, write, policy, test" for the script to work.

# Name of this script should exactly be "ddns-updater"

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Import global variables
:global cfZoneId
:global cfDnsApiToken

# Setup web request parameters
:local url    "https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$DomainId"
:local header "Authorization: Bearer $cfDnsApiToken, content-type: application/json"
:local data   "{\"type\":\"$RecordType\",\"name\":\"$DomainName\",\"content\":\"$WanIP\",\"ttl\":$RecordTTL}"

# Update DNS record
:log info ("[ddns-updater] Updating \"$DomainName\" DNS record to $WanIP ...");
/tool fetch \
    http-method=put \
    mode=https \
    http-header-field=$header \
    http-data=$data \
    url=$url \
    as-value \
    output=user;

:delay 10s;

# Check update result
/ip dns cache flush;
:local NewResolvedIP [:resolve domain-name=$DomainName type=$ResolveType];
:if ($NewResolvedIP = $WanIP) do={
    :log info ("[ddns-updater] Successfully updated \"$DomainName\" DNS record.");
} else={
    :log error ("[ddns-updater] Failed to update \"$DomainName\" DNS record.");
}
