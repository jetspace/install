clear
cat /logo.ascii
echo "A free Arch Based Distro"
echo "------------------------"
echo -e "\n\n" # New Lines

echo "This is the Afterinstall Script, it will setup GNOME and other JetSpace Stuff" #When Done ;-)
echo "[ENTER]"

read -s

echo "Now installing GNOME desktop..."

pacman -S gnome xorg-drivers xorg-server xorg-init xorg-utils xorg-server-utils xterm dconf

echo "GNOME installed, now installing other GNOME tools:"

pacman -S gnome-tweak-tool gnome-shell-extensions acpid ntp dbus avahi cups

systemctl enable cronie
systemctl enable acpid
systemctl enable ntpd
systemctl enable avahi-daemon
systemctl enable cups

echo "Done, now confirming GDM"

pacman -S gdm

echo "setting GDM to boot!"

systemctl enable gdm

echo "Now using JetSpceLogo!"

mkdir /opt #just to be sure!
mkdir /opt/login
cp /logo.png /opt/login/logo.png
echo "[org/gnome/login-screen]" > /etc/dconf/db/gdm.d/02-logo
echo "logo='/opt/login/logo.png'" >> /etc/dconf/db/gdm.d/02-logo
dconf update
clear
echo "As the last step, you have to create a user!"
echo "Username: "
read USERNAME
useradd -m -g users -s /bin/bash $USERNAME
gpasswd -a $USERNAME floppy
gpasswd -a $USERNAME kvm
gpasswd -a $USERNAME log
gpasswd -a $USERNAME network
gpasswd -a $USERNAME lp
gpasswd -a $USERNAME uucp
passwd $USERNAME
