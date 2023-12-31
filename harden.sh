#!/bin/bash

sudo apt update
sudo apt upgrade -y

# Install Build and Development Packages
sudo apt install -y build-essential curl

# Network Security
sudo ufw enable
sudo ufw default deny incoming
sudo ufw reload

# Install hblock (see https://github.com/hectorm/hblock)
curl -o /tmp/hblock 'https://raw.githubusercontent.com/hectorm/hblock/v3.4.2/hblock' \
  && echo 'a7d748b69db9f94932333a5b5f0c986dd60a39fdf4fe675ad58364fea59c74b4  /tmp/hblock' | shasum -c \
  && sudo mv /tmp/hblock /usr/local/bin/hblock \
  && sudo chown 0:0 /usr/local/bin/hblock \
  && sudo chmod 755 /usr/local/bin/hblock
  
curl -o '/tmp/hblock.#1' 'https://raw.githubusercontent.com/hectorm/hblock/v3.4.2/resources/systemd/hblock.{service,timer}' \
  && echo '45980a80506df48cbfa6dd18d20f0ad4300744344408a0f87560b2be73b7c607  /tmp/hblock.service' | shasum -c \
  && echo '87a7ba5067d4c565aca96659b0dce230471a6ba35fbce1d3e9d02b264da4dc38  /tmp/hblock.timer' | shasum -c \
  && sudo mv /tmp/hblock.{service,timer} /etc/systemd/system/ \
  && sudo chown 0:0 /etc/systemd/system/hblock.{service,timer} \
  && sudo chmod 644 /etc/systemd/system/hblock.{service,timer} \
  && sudo systemctl daemon-reload \
  && sudo systemctl enable hblock.timer \
  && sudo systemctl start hblock.timer

# Malware Scanners
sudo apt install -y chkrootkit rkhunter lynis checksec clamav clamav-daemon
sudo rkhunter --propupd

sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl enable clamav-freshclam --now

# TODO: add code to automate clamav scanning

# Kernel Security
cat sysctl-baseline.conf | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


# Apparmor
sudo apt install -y apparmor-profiles apparmor-profiles-extra
sudo apt install -y libpam-apparmor dh-apparmor apparmor-utils apparmor-notify apparmor-easyprof
sudo systemctl enable --now apparmor
echo "session optional     pam_apparmor.so order=user,group,default" | sudo tee -a /etc/pam.d/su
sudo apparmor_parser -r -T -W /etc/apparmor.d/pam_binaries /etc/apparmor.d/pam_roles

# Hardened Firefox user.js
wget -O "$HOME"/user.js https://raw.githubusercontent.com/arkenfox/user.js/master/user.js
chown "$USER":"$USER" "$HOME"/user.js
cp "$HOME"/user.js "$HOME"/.mozilla/firefox/*.default
mv "$HOME"/user.js "$HOME"/.mozilla/firefox/*.default-release


# Entropy
sudo apt install -y rng-tools jitterentropy-rngd
sudo systemctl enable --now jitterentropy

# Filesystem and Integrity Monitoring
sudo apt install -y sxid
sudo find /etc -name sxid.conf -type f -exec sed -i 's/ALWAYS_NOTIFY = "no"/ALWAYS_NOTIFY = "yes"/g' {} +
sudo find /etc -name sxid.conf -type f -exec sed -i 's/LISTALL = "no"/LISTALL = "yes"/g' {} +

sudo touch /var/spool/cron/crontabs/root
echo "0 */1 * * * /usr/bin/sxid --spotcheck -l" | sudo tee -a /var/spool/cron/crontabs/root

sudo apt install aide -y
sudo aideinit
sudo cp /var/lib/aide/aide.db{.new,}
sudo update-aide.conf
sudo cp /var/lib/aide/aide.conf.autogenerated /etc/aide/aide.conf
echo "*/30 * * * * /usr/bin/aide -c /etc/aide/aide.conf -C" | sudo tee -a /var/spool/cron/crontabs/root
echo "!/home/" | sudo tee -a /etc/aide/aide.conf
echo "!/proc/" | sudo tee -a /etc/aide/aide.conf
echo "!/media/" | sudo tee -a /etc/aide/aide.conf
