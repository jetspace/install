#
#This file will setup multimedia
#

WINY=0
WINX=0

dialog --textbox txt/multimedia.en $WINY $WINX

arch-chroot /mnt pacman -S xorg mesa libgl   #base env.
arch-chroot /mnt pacman -S xf86-input-evdev  #hotpulg

#GRAPHIC CARD DRIVER LATER

arch-chroot /mnt pacman -S ttf-dejavu ttf-ms-fonts #fonts

arch-chroot /mnt pacman -S gnome gnome-extra gnome-system-tools #All GNOME tools
