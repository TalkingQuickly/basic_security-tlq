# TalkingQuickly Server Security

This is a simple chef recipe to automate the standard lock down steps on a fresh Ubuntu install, these are:

- Install Fail2Ban
- Install UFW (Firewall)
- Install Unattended Upgrades
- Set the system to download updates daily
- Disable SSH Password auth
- Allow SSH traffic through the firewall
- Allow any pre defined traffic through the firewall

## Firewall

This recipe will look for a key firewall_allow in the node definition.
If it is defined it will expect it to be an array of hashes in the form:

{ip: an_ip_address, port; a_port}

For each rule, the specified ip address will be granted access to the
specified port on the current node.

## Root Login

Root login is left as enabled. It's unclear what the benefit of
disabling it is when password auth is disabled.

## Ubuntu 14.04

Ubuntu 14.04 disabled managing ssh with the init.d script which the current chef release will try and do when it reaches the below part of `recipes/default.rb`:

``` ruby
service 'ssh' do                                             
 action :restart                                            
end
```

In 14.04 the script returns 1 not 0 and so chef will fail. This will be fixed in the upcoming chef release (see: <https://tickets.opscode.com/browse/COOK-3910>) but in the mean time, if you're using Ubuntu 14.04, you can fork the cookbook and make the following amend:

``` ruby
service 'ssh' do                                             
 start_command "service ssh start"                          
 restart_command "service ssh restart"                      
 action :restart                                            
end
```

The book and tutorials this cookbook accompanies will remain focussed on Ubuntu 12.04 until kinks like this are ironed out so this recipe won't receive the change on master since the Upstream chef change will resolve it.
