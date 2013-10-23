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

# TODO should specify which locals to load in the node file

bash 'adding GB locales' do
  user 'root'
  code <<-EOC
    echo "en_GB ISO-8859-1" >> /var/lib/locales/supported.d/local
    echo "en_GB.UTF-8 UTF-8" >> /var/lib/locales/supported.d/local
    dpkg-reconfigure locales
    update-locale
  EOC
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

# now allow SSH traffic through the firewall and restart SSH
bash "opening ufw for ssh traffic" do
  user "root"
  code <<-EOC
ufw allow 22
ufw --force enable
ufw allow 22
  EOC
end

service 'ssh' do
  action :restart
end

# if we've specified firewall rules in the node definition
# then apply them here
if node['firewall_allow']
  node['firewall_allow'].each do |rule|
    bash "open ufw from #{rule['ip']} on port #{rule['port']}" do
      user "root"
      code "ufw allow from #{rule['ip']} to any port #{rule['port']}"
    end
  end
end
