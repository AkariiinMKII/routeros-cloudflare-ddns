# This script is used for triggering the "ddns-initialize-variables" script in the scheduler

# Requires policy to be set to "read, write, policy, test" for the script to work.

# It is recommended to set the script to run every minute, but you can adjust the interval as needed.

# Tested on RouterOS 7.18.2
######################################################################################

/system script run "ddns-initialize-variables"
