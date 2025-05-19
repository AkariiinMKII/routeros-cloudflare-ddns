# This script compares IPv6 GUA with the DNS record, and calls the ddns-updater if they are different.

# Requires policy to be set to "read, write, policy, test" for the script to work.

# Name of this script should exactly be "ddns-check-profile1"

# Supports IPv6 only in current version.

# Tested on RouterOS 7.18.2
######################################################################################

# Import DDNS profile
# Each profile needs a separate script to run.
# Replace ALL "DdnsProfile1" in this script with the profile name in "ddns-initialize-variables" script.
:global DdnsProfile1;
:local CurrentProfile $DdnsProfile1;
:local DomainName ($CurrentProfile->"DomainName");

# Checkup Domain ID
:if ([:len ($CurrentProfile->"DomainId")] = 0) do={
    :local FetchDomainId [:parse [/system script get "ddns-fetch-domain-id" source]];
    :local DomainId [$FetchDomainId Profile=$CurrentProfile];
    :if ([:len $DomainId] = 0) do={
        :error ("[ddns-checker] Failed to get \"$DomainName\" domain ID.");
    } else {
        :log info ("[ddns-checker] Get \"$DomainName\" domain ID: $DomainId");
        :set ($CurrentProfile->"DomainId") $DomainId;
        :set DdnsProfile1 $CurrentProfile;
    }
}

# Import global variables
:global cfZoneId;
:global cfDnsApiToken;
:global WanIP6Prefix;

:if ([:len $WanIP6Prefix] = 0) do={
    :error ("[ddns-checker] Invalid IPv6 GUA prefix.");
}

# Generate WAN IPv6 GUA
:local WanIP6 ($WanIP6Prefix . ($CurrentProfile->"WanIP6Tail"));

#Checkup DNS record
:local FetchDnsRecord [:parse [/system script get "ddns-fetch-dns-record" source]];
:local ResolvedIP [$FetchDnsRecord Profile=$CurrentProfile];
:if ([:len $ResolvedIP] = 0) do={
    :error ("[ddns-checker] Failed to get \"$DomainName\" DNS record.");
}

:if ($ResolvedIP != $WanIP6) do={
    :log info ("[ddns-checker] Get WAN IPv6 GUA: $WanIP6");
    :log info ("[ddns-checker] Get \"$DomainName\" DNS record: $ResolvedIP");
    :log info ("[ddns-checker] Detected IP change, start updating DNS record ...");

    # Update DNS record
    :local UpdateDnsRecord [:parse [/system script get "ddns-update-dns-record" source]];
    :set ($CurrentProfile->"WanIP6") $WanIP6;
    $UpdateDnsRecord Profile=$CurrentProfile;
}
