# routeros-cloudflare-ddns

## Q: So what is this stuff?

A: It is a set of scripts for RouterOS which updates Cloudflare DNS records with your current IPv6 addresses.

## Q: And what is the difference with others?

A: It is designed to be expandable, you can add sub-scripts to update multiple records in a zone.

## Q: Okay then tell me how to use it?

A: Well, let's go through the scripts.

1. **[ddns-initialize-variables.rsc](./Scripts/ddns-initialize-variables.rsc)**: This script initializes the necessary variables for the DDNS update process. You need to setup some variables in this script to make it work.

    - The Cloudflare APIs

        - `cfZoneId`: The Cloudflare zone ID for the domain you want to update.
        - `cfDnsApiToken`: The API token for Cloudflare with permissions to edit DNS records.

    - The router stuff

        - `Wan6Interface`: The name of the WAN interface that has the IPv6 prefix delegated.

    - The domain name profiles (each DNS record needs a set of variables)

        - `DomainName`: The domain name you want to update (e.g. `"www.example.com"`). You may need to create a new record on Cloudflare in advance.
        - `WanIP6Tail`: The last part of the IPv6 address that you want to update, it should start with `:` (e.g. `":1"`). You may need to modify system settings to make the address static, such as enable EUI64 on Windows PCs.
        - `RecordType`: The type of DNS record to update, we only support `"AAAA"` in current version.
        - `RecordTTL`: The TTL for the DNS record, in seconds.
        - `Proxied`: Whether the DNS record should be proxied through Cloudflare (true or false).

    - The script triggers

        - Uncomment or add the line `/system script run "ddns-check-profile*";` to enable the script that updates the DNS records for each domain name profile.

2. **[ddns-check-profile1.rsc](./Scripts/ddns-check-profile1.rsc)**: This script checks the current DNS records and triggers the update process for each domain name profile. Each profile needs a separate script, just duplicate the script and replace `DdnsProfile1` with the profile name you set in previous script.

3. **[ddns-fetch-domain-id.rsc](./Scripts/ddns-fetch-domain-id.rsc)**: This script fetches the domain ID for the specified domain name from Cloudflare. **It is for function importing and should not be run directly.**

4. **[ddns-fetch-dns-record.rsc](./Scripts/ddns-fetch-dns-record.rsc)**: This script fetches the DNS record information for the specified domain name from Cloudflare. **It is for function importing and should not be run directly.**

5. **[ddns-update-dns-record.rsc](./Scripts/ddns-update-dns-record.rsc)**: This script updates the DNS record for the specified domain name in Cloudflare. **It is for function importing and should not be run directly.**

6. **[ddns-initializer-timer.rsc](./Scheduler/ddns-initializer-timer.rsc)**: This script is a scheduler that runs the `ddns-initialize-variables.rsc` script at a specified interval, add it to the scheduler module in RouterOS and specify the interval you want it to run. It is recommended to run it every minute.

7. **[ddns-checker-timer.rsc](./Scheduler/ddns-checker-timer.rsc)**: This script is a scheduler that runs the `ddns-check-profile*.rsc` and so on script at a specified interval, add it to the scheduler module in RouterOS and specify the interval you want it to run. It is recommended to run it every 10 minutes. Uncomment or add the line `/system script run "ddns-check-profile*";` for each profile.
