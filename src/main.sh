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

dialog --no-lines --textbox txt/intro.en $WINY $WINX #Welcome
dialog --no-lines --textbox txt/mit.en   $WINY $WINX #License

#check license agreement

dialog --no-lines --yesno "$(cat txt/agree.en)" $WINY $WINX

if [ "$?" != "0" ] #user do not agree
then
dialog --no-lines --textbox txt/sorry-1.en $WINY $WINX
clear
exit
fi
clear
dialog --no-lines --textbox txt/use.en $WINY $WINX

#Get keymap first
while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --radiolist "Select your Keyboard Layout" $WINY $WINX 0 "de-latin1" "Deutsch (german)" 0 "us" "english (english)" 0  3>&1 1>&2 2>&3`
done

KEYMAP=$selection

loadkeys $KEYMAP

selection=""
#Now, get the network type
while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --radiolist "Select your Network Type:" $WINY $WINX 0 "LAN" "wired network" 0 "WiFi" "wireless network" 0 3>&1 1>&2 2>&3`

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
selection=`dialog --no-lines --no-cancel --inputbox "Please select a drive to formart:\n $(ls /dev | sed s"/\t/\n/"g | grep sd[[:alpha:]]$ && ls /dev | sed s"/\t/\n/"g | grep hd[[:alpha:]]$)" $WINY $WINX 3>&1 1>&2 2>&3`
done

DRIVE=$selection
selection=""

dialog --textbox txt/part.en $WINY $WINX

cfdisk $DRIVE #formart the drive

#PART DISK
while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --inputbox "Number of data partition:" $WINY $WINX 3>&1 1>&2 2>&3`
done

DATAPART="/dev/$DRIVE$selection"
selection=""

while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --inputbox "Number of SWAP partition:"	$WINY $WINX 3>&1 1>&2 2>&3`
done

SWAPPART="/dev/$DRIVE$selection"
selection=""

dialog --no-lines --textbox txt/fs.en $WINY $WINX

while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --radiolist "Select filesystem:" $WINY $WINX 0 "ext4" "EXT4 filesystem" 0 "ext3" "EXT3 filesystem" 0 "ext2" "EXT2 filesystem" 0 3>&1 1>&2 2>&3`
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

dialog --no-lines --title "Summary:" --textbox install.txt $WINY $WINX

dialog --no-lines --yesno "Are these infos correct?" $WINY $WINX

if [ "$?" != "0" ]
then
dialog --no-lines --msgbox "Install Failed!, please restart." $WINY $WINX
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


dialog --no-lines --textbox txt/soft.en $WINY $WINX

#PACSTRAP

PACKS="base base-devel"			#Change this if needed
PACKAGES="git ncurses tree dialog"	#Change this if needed

pacstrap /mnt $PACKS $PACKAGES

#FAKEROOT

#END FAKEROOT

#UNMOUNT

#Reboot


