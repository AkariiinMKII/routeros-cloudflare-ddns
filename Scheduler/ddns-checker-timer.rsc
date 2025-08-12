# This script is used for triggering the "ddns-check-profile1" and similar scripts in the scheduler

# Requires policy to be set to "read, write, policy, test" for the script to work.

# It is recommended to set the script to run every 10 minutes, but you can adjust the interval as needed.

# Tested on RouterOS 7.18.2
######################################################################################

/system script run "ddns-check-profile1"
# /system script run "ddns-check-profile2"
