# This script fetches DNS reocrd from Cloudflare DNS API for a given domain name.

# This script does not require any permissions as it is only used for function importing.

# Name of this script should exactly be "ddns-fetch-dns-record"

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Import global variables
:global cfZoneId;
:global cfDnsApiToken;

# Resolve local variables
:local DomainId ($Profile->"DomainId");

# Generate web request parameters
:local url    "https://api.cloudflare.com/client/v4/zones/$cfZoneId/dns_records/$DomainId";
:local header "Authorization: Bearer $cfDnsApiToken, content-type: application/json";

# Fetch DNS record
:local Record [/tool fetch \
    http-method=get \
    mode=https \
    http-header-field=$header \
    url=$url \
    as-value \
    output=user];

# Resolve data and return result
:set Record [:deserialize from=json value=($Record->"data")];
:local ResolvedIP (($Record->"result")->"content");
:return $ResolvedIP;
