clear
cat /logo.ascii
echo "A free Arch Based Distro"
echo "------------------------"
echo -e "\n\n" # New Lines

echo "This is the Afterinstall Script, it will setup GNOME and other JetSpace Stuff" #When Done ;-)
echo "[ENTER]"

read -s

echo "Now installing GNOME desktop..."

pacman -S gnome

echo "GNOME installed, now installing other GNOME tools:"

pacman -S gnome-extra gnome-tweak-tool gnome-shell-extension-user-theme networkmanager network-manager-applet system-config-printer
