#!/bin/bash

# Kali Linux ISO recipe for : TOR support and sdmem wipe
#########################################################################################
# Desktop 	: GNOME
# Metapackages	: kali-linux-top10
# ISO size 	: 1.36 GB 
# Special notes	: Non root user installation enabled through preseed.cfg. 
#		: This script is not meant to run unattended.
# Look and Feel	: Custom wallpaper and terminal configs through post install hooks.
# Background	: http://www.offensive-security.com/kali-linux/kali-linux-recipes/
#########################################################################################

# Update and install dependencies

apt-get update
apt-get install git live-build cdebootstrap devscripts -y

# Clone the default Kali live-build config.

git clone git://git.kali.org/live-build-config.git

# Get the source package of the debian installer. 
# The default Kali preseed file lives here, and will need changing for non-root user support.

apt-get source debian-installer

# Let's begin our customisations:

cd live-build-config

# The user doesn't need the kali-linux-full metapackage, we overwrite with our own basic packages.
# This includes the debian-installer and the kali-linux-top10 metapackage (commented out for brevity of build, uncomment if needed).

cat > config/package-lists/kali.list.chroot << EOF
kali-root-login
kali-defaults
kali-menu
kali-debtags
kali-archive-keyring
debian-installer-launcher
alsa-tools
locales-all
tor
secure-delete
xorg
kali-linux-full
EOF

# Add the new Mate 1.8 as a Windows Manager.
# We instruct live-build to add external MATE repositories and add relevant keys.
# Taken from http://wiki.mate-desktop.org/download

#mkdir -p config/archives/
#echo "deb http://repo.mate-desktop.org/archive/1.8/debian/ wheezy main" > config/archives/mate.list.chroot
#wget http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg -O config/archives/mate.key.chroot

# We download new icons and apply them.

mkdir ~/.icons
wget http://buuficontheme.free.fr/buuf3.2.tar.xz
tar Jxf buuf3.2.tar.xz -C ~/.icons/
dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface icon-theme 'buuf3.2'

# We add a chroot hook to add the MATE archive-keyring, and install MATE. 
# We even configure some of the terminal settings and wallpaper.

#cat > config/hooks/mate.chroot<< EOF
#!/bin/bash
#wget http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg
#apt-key add mate-archive-keyring.gpg
#rm -rf mate-archive-keyring.gpg

#apt-get --yes --force-yes --quiet --allow-unauthenticated install mate-core mate-desktop-environment-extra

#dbus-launch --exit-with-session gsettings set org.mate.background picture-filename '/usr/share/wallpapers/kali/contents/images/kali_linux.jpg'
#dbus-launch --exit-with-session gsettings set org.mate.interface gtk-theme 'BlackMATE'
#dbus-launch --exit-with-session gsettings set org.mate.interface icon-theme 'mate'
#dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-darkness 0.86
#dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-type 'transparent'
#dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-color '#FFFFFFFFDDDD'
#dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ scrollback-unlimited true

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
