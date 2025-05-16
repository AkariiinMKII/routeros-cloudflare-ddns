# This script compares IPv6 GUA with the DNS record, and calls the ddns-updater if they are different.

# Requires policy to be set to "read, write, policy, test" for the script to work.

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Setup DNS record parameters
# Replace with your own Domain name and Domain ID
:local DomainName "_DOMAIN_NAME_";
:local DomainId "_DOMAIN_ID_";

# Setup local variables
:local RecordType "AAAA";
:local RecordTTL 300;

:local ResolveType "ipv6";
:local WanIP6Tail "::1";

# Import global variables and functions
:global WanIP6Prefix

:global UpdateDnsRecord

# Check up WAN IP and DNS record
:local WanIP ($WanIP6Prefix . $WanIP6Tail);

/ip dns cache flush;
:local ResolvedIP [:resolve domain-name=$DomainName type=$ResolveType];

:if ($ResolvedIP != $WanIP) do={
    :log info ("[ddns-checker] Get WAN IPv6 GUA address: $WanIP");
    :log info ("[ddns-checker] Get \"$DomainName\" DNS record: $ResolvedIP");
    :log info ("[ddns-checker] Detected IP change, starting ddns-updater ...");
    # Use ddns-updater to update DNS record
    $UpdateDnsRecord \
        DomainName=$DomainName \
        DomainId=$DomainId \
        RecordType=$RecordType \
        RecordTTL=$RecordTTL \
        WanIP=$WanIP \
        ResolveType=$ResolveType;
} else={
    :log info ("[ddns-checker] \"$DomainName\" DNS record is up to date, skip update.");
}
