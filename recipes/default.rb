# list of security specific packages to be installed
packages = %w(
  fail2ban
  ufw
  unattended-upgrades
)

# install the above security packages
packages.each { |name| package name }

# Set the system to install security updates automatically each day
file '/etc/apt/apt.conf.d/10periodic' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF
  APT::Periodic::Update-Package-Lists "1";
  APT::Periodic::Download-Upgradeable-Packages "1";
  APT::Periodic::AutocleanInterval "7";
  APT::Periodic::Unattended-Upgrade "1";
  EOF
end

# updated time from central server every day, particularly important
# when certs are involved.

file '/etc/cron.daily/ntpdate' do
  owner 'root'
  group 'root'
  mode '0755'
  content <<-EOF
#!/bin/sh

ntpdate -s ntp.ubuntu.com pool.ntp.org
  EOF
end

# lock down SSH, primarily disable password logins.
# Make sure you've copied your public key to the root user otherwise
# deploying is going to be tricky...

# path to ssh config
sshd_config = '/etc/ssh/sshd_config'

# changes to make to the config file
seds = [
  's/^#PasswordAuthentication yes/PasswordAuthentication no/g',
  's/^X11Forwarding yes/X11Forwarding no/g',
  's/^UsePAM yes/UsePAM no/g'
]

bash 'ssh hardening' do
  user 'root'
  code <<-EOC
    #{seds.map { |rx| "sed -i '#{rx}' #{sshd_config}" }.join("\n")}
  EOC
end

service 'ssh' do
  action :restart
end

# now allow SSH traffic through the firewall and restart SSH
# unless otherwise specified, block everything
bash "opening ufw for ssh traffic" do
  user "root"
  code <<-EOC
  ufw default deny
  ufw allow 22
  ufw --force enable
  EOC
end


# if we've specified firewall rules in the node definition
# then apply them here. These should be in the format:
# {"port": "x", "ip": "xxx.xxx.xxx.xxx"}
if node['firewall_allow']
  node['firewall_allow'].each do |rule|
    bash "open ufw from #{rule['ip']} on port #{rule['port']}" do
      user "root"
      code "ufw allow from #{rule['ip']} to any port #{rule['port']}"
    end
  end
end
