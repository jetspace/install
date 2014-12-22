#
#This file will setup multimedia
#

WINY=0
WINX=0

dialog --textbox txt/multimedia.en $WINY $WINX

arch-chroot /mnt pacman -S xorg mesa libgl   #base env.

#GRAPHIC CARD DRIVER LATER

arch-chroot /mnt pacman -S ttf-dejavu  #fonts

arch-chroot /mnt pacman -S gnome gnome-extra #All GNOME tools
arch-chroot /mnt pacman -S xterm xorg-xinit  #tools

arch-chroot /mnt systemctl enable gdm
