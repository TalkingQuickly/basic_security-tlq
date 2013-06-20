# TalkingQuickly Server Security

This is a simple chef recipe to automate the standard lock down steps on a fresh Ubuntu install, these are:

- Install Fail2Ban
- Install UFW (Firewall)
- Install Unattended Upgrades
- Set the system to download updates daily
- set the GB Locale (not security exactly but relevant for SSL stuff)
- Disable SSH Password auth
- Allow SSH traffic through the firewall
- Allow any pre defined traffic through the firewall

## Root Login

Root login is left as enabled. This is primarily to make chef
deployments easy. It's also unclear what the benefit in disabling root
login is, if a malicious party is getting SSH access to ANY account when
an SSH key is required for auth you're in trouble anyway. 
