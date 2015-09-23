#!/bin/bash

# Kali Linux ISO recipe for : TOR support and sdmem wipe, codename "Tanto"
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
apt-get install git live-build cdebootstrap debootstrap devscripts -y -qq

# Clone the default Kali live-build config.

git clone git://git.kali.org/live-build-config.git

# Let's begin our customisations:

cd live-build-config

# We add additional packages to the kali list.

cat >> kali-config/variant-default/package-lists/kali.list.chroot << EOF

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
torsocks
xorg
EOF

# We download new icons and apply them.

cd kali-config/common/includes.chroot/
wget http://buuficontheme.free.fr/buuf3.2.tar.xz
mkdir .icons && tar Jxf buuf3.2.tar.xz -C .icons/
dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface icon-theme 'buuf3.2'
rm buuf3.2.tar.xz

# We download and link a wget-all script.

mkdir .bin && cd .bin
wget https://raw.githubusercontent.com/thomhastings/os-scripts/master/wgetall.sh
chmod +x wgetall.sh
ln -s wgetall.sh wget-all

# We add hooks from knife by kaneda.

cd ../hooks
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0010sleep.chroot
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0020wipe-mem.chroot
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0030ronin-install.chroot
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0060hashkill-install.chroot
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0080quicksnap-install.chroot
# wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/hooks/0090theme.chroot # commented out until tanto.png can be included
sed -i 's/etc\/init.d/lib\/live\/config/' 0020wipe-mem.chroot # update mem=wipe to new location of sdmem (init.d deprecated)
chmod +x *.chroot
cd ../includes.chroot/lib/live/config
wget https://raw.githubusercontent.com/kaneda/knife/master/live-build-config/config/includes.chroot/etc/init.d/sdmem
chmod +x sdmem

# TODO: Incorporate https://github.com/DanMcInerney/fakeAP

# Go ahead and run the build!
lb build
