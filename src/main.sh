#!/bin/bash
#JetSpace installer rewrite
#Licensed under MIT license

WINY=0
WINX=0

#clear the screen
clear

echo "Welcome to JetSpace!, please wait while the setup is loading..."

#BEGIN LOAD OPERATIONS

#install dialog on the live iso
#also check other tools

#END LOAD OPERATIONS

dialog  --textbox txt/intro.en $WINY $WINX #Welcome
dialog  --textbox txt/mit.en   $WINY $WINX #License

#check license agreement

dialog  --yesno "$(cat txt/agree.en)" $WINY $WINX

if [ "$?" != "0" ] #user do not agree
then
dialog  --textbox txt/sorry-1.en $WINY $WINX
clear
exit
fi
clear
dialog  --textbox txt/use.en $WINY $WINX

#Get keymap first
while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --radiolist "Select your Keyboard Layout" $WINY $WINX 0 "de-latin1" "Deutsch (german)" 0 "us" "english (english)" 0  3>&1 1>&2 2>&3`
done

KEYMAP=$selection

loadkeys $KEYMAP

selection=""
#Now, get the network type
while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --radiolist "Select your Network Type:" $WINY $WINX 0 "LAN" "wired network" 0 "WiFi" "wireless network" 0 3>&1 1>&2 2>&3`

#SKIP WIFI BECAUSE IT IS NOT IMPLEMENTED YET!
if [ "$selection" == "WiFi" ]
then
selection=""
fi
done
#SET NETWORK

NETWORK=$selection

if [ "$NETWORK" == "LAN" ]
then
dhcpd #start dhcp deamon
fi

dialog --textbox txt/format.en $WINY $WINX

selection=""

while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --inputbox "Please select a drive to formart:\n $(ls /dev | sed s"/\t/\n/"g | grep sd[[:alpha:]]$ && ls /dev | sed s"/\t/\n/"g | grep hd[[:alpha:]]$)" $WINY $WINX 3>&1 1>&2 2>&3`
done

DRIVE=$selection
selection=""

dialog --textbox txt/part.en $WINY $WINX

cfdisk "/dev/$DRIVE" #formart the drive

#PART DISK
while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --inputbox "Number of data partition:" $WINY $WINX 3>&1 1>&2 2>&3`
done

DATAPART="/dev/$DRIVE$selection"
selection=""

while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --inputbox "Number of SWAP partition:"	$WINY $WINX 3>&1 1>&2 2>&3`
done

SWAPPART="/dev/$DRIVE$selection"
selection=""

dialog  --textbox txt/fs.en $WINY $WINX

while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --radiolist "Select filesystem:" $WINY $WINX 0 "ext4" "EXT4 filesystem" 0 "ext3" "EXT3 filesystem" 0 "ext2" "EXT2 filesystem" 0 3>&1 1>&2 2>&3`
done

FILESYSTEM=$selection

selection=""

#write summary

echo "keymap : $KEYMAP"     >  install.txt
echo "network: $NETWORK"    >> install.txt
echo "drive  : $DRIVE"      >> install.txt
echo " -data : $DATAPART"   >> install.txt
echo "  -fs  : $FILESYSTEM" >> install.txt
echo " -swap : $SWAPPART"   >> install.txt

dialog  --title "Summary:" --textbox install.txt $WINY $WINX

dialog  --yesno "Are these infos correct?" $WINY $WINX

if [ "$?" != "0" ]
then
dialog  --msgbox "Install Failed!, please restart." $WINY $WINX
exit
fi

#NOW WORK

#Format drive, enable SWAP, mount data drive

echo "Creating File system..."
mkfs.$FILESYSTEM $DATAPART 	#FORMAT DATA-PART
mount $DATAPART /mnt		#mount DATA-PART
echo "Creating SWAP..."
mkswap $SWAPPART		#Create SWAP part
swapon $SWAPPART		#Enable SWAP
echo "Partitioning Compleate!"


dialog  --textbox txt/soft.en $WINY $WINX

#PACSTRAP

PACKS="base base-devel"			#Change this if needed
PACKAGES="git ncurses tree dialog"	#Change this if needed

pacstrap /mnt $PACKS $PACKAGES

#Now, generate FSTAB

genfstab -p /mnt >> /mnt/etc/fstab

#hostname

selection=""
while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel --inputbox "$(cat txt/hostname.en)" $WINY $WINX 3>&1 1>&2 2>&3`
done
HOSTN="$selection"

echo $HOSTN > /mnt/etc/hostname # set hostname

selection=""

while [ "$selection" == "" ]
do
selection=`dialog  --no-cancel  --radiolist "Select your locale:" $WINY $WINX 0 "de_DE.utf8" "Deutsch" 0 "en_US.utf8" "English (US)" 0 "en_GB.utf8" "English (GB)" 0 3>&1 1>&2 2>&3`
done

LOCALE="$selection"

echo "LANG=$LOCALE" > /mnt/etc/locale.conf
echo "LC_NUMERIC=$LOCALE" >> /mnt/etc/locale.conf
echo "LC_TIME=$LOCALE" >> /mnt/etc/locale.conf
echo "LC_DATE=$LOCALE" >> /mnt/etc/locale.conf

arch-chroot /mnt "ln /usr/share/zoneinfo/UTC /etc/localtime"

dialog  --textbox txt/local.en $WINY $WINX

nano /mnt/etc/locale.gen

arch-chroot /mnt "locale-gen"

#Kernel Image

dialog   --yesno "Do you want to edit the Kernel image configuration file? (advanced mode)" $WINY $WINX

if [ "$?" == "0" ]
then
nano /mnt/etc/mkinitcpio.conf
fi

#Generate image

arch-chroot /mnt mkinitcpio -p linux

#Save Keymap

echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf

#root password

dialog  --textbox txt/pass.en $WINY $WINX

arch-chroot /mnt "passwd"

#Syslinux

arch-chroot /mnt pacman -S syslinux
arch-chroot /mnt syslinux-install_update -i -a -m

#Set network

if [ "$NETWORK" == "LAN" ]
then
arch-chroot /mnt systemctl enable dhcpcd
fi

bash src/second.sh

bash config/syslinux/install.sh $DATAPART

dialog  --textbox txt/done.en $WINY $WINX

#UNMOUNT

unmount /mnt


#Reboot
reboot
