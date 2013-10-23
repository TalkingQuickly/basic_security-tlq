#
# Author:: Ben Dixon
# Cookbook Name:: basic_security-tlq
# Attributes:: default
#

# Default to an empty array (e.g. firewall closed).
# should be popualted in node or role definitions with hashes in
# the format:
# {"port": "x", "ip": "xxx.xxx.xxx.xxx"}
# which means allow traffic on port x from ip xxx.xxx.xxx.xxx
default[:firewall_allow] = []
