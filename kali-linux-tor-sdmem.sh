#!/bin/bash

# Kali Linux ISO recipe for : TOR support and sdmem wipe
#########################################################################################
# Desktop 	: GNOME
# Metapackages	: kali-linux-full
# ISO size 	: ?.?? GB 
# Special notes	: Non root user installation enabled through preseed.cfg. 
#	              : This script is not meant to run unattended.
# Look and Feel	: Custom icons and terminal configs through post install hooks.
# Background	: http://www.offensive-security.com/kali-linux/kali-linux-recipes/
#########################################################################################

# Update and install dependencies

apt-get update
apt-get install git live-build cdebootstrap debootstrap devscripts -y

# Clone the default Kali live-build config.

git clone git://git.kali.org/live-build-config.git

# Get the source package of the debian installer. 
# The default Kali preseed file lives here, and will need changing for non-root user support.

apt-get source debian-installer

# Let's begin our customisations:

cd live-build-config

# Add additional packages to the kali list.

cat > kali-config/variant-default/package-lists/kali.list.chroot << EOF

# Customizations
kali-root-login
kali-defaults
kali-menu
kali-debtags
kali-archive-keyring
debian-installer-launcher
alsa-tools
figlet
htop
privoxy
secure-delete
tor
xorg
EOF

# Download new icons and apply them.

mkdir ~/.icons
wget http://buuficontheme.free.fr/buuf3.2.tar.xz
tar Jxf buuf3.2.tar.xz -C ~/.icons/
dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface icon-theme 'buuf3.2'
rm buuf3.2.tar.xz

cp -rf /root/.icons /etc/skel/

EOF

# We modify the default Kali preseed which disables normal user creation. 
# We copied this from the debian installer package we initially downloaded.

mkdir -p config/debian-installer
cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

# Go ahead and run the build!
lb build
