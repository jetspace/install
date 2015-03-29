#!/bin/bash
#JetSpace installer rewrite
#Licensed under MIT license

#All Included Modules
MODULES="license_dialog\nget_keymap\nnetwork_setup\ndisk_part\nsum_all_up\napply_parts\nsoftware_setup\nconf_file_setup\nramdisk_create\nkeymap_save\nset_root_key\nsyslinux_setup\nfinish_base_install\nreboot_install_disk"

WINY=0
WINX=0

#clear the screen
clear

echo "Welcome to JetSpace!, please wait while the setup is loading..."

#BEGIN LOAD OPERATIONS

#install dialog on the live iso
#also check other tools

#END LOAD OPERATIONS

function license_dialog ()
{
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
}

function get_keymap ()
{
  #Get keymap first
  selection=""
  while [ "$selection" == "" ]
  do
    local keymaps="$(localectl --no-pager list-keymaps | sed 's/[a-zA-Z0-9_\-]*/& &/')"
    selection=`dialog  --no-cancel --menu "Select your Keyboard Layout" $WINY $WINX 0 $keymaps 3>&1 1>&2 2>&3`
  done

  KEYMAP=$selection

  loadkeys $KEYMAP

  selection=""
}

function network_setup ()
{
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
  dhcpcd #start dhcp deamon
  fi

  ping -c 2 www.google.com > /dev/null # 2 Pings to verify network
	if [ $? -ne  0 ]
    then
      dialog --no-cancel --msgbox "Setting up Network failed, restarting..."
      network_setup
    fi


}

function disk_part ()
{

  dialog --textbox txt/format.en $WINY $WINX

  selection=""

  while [ "$selection" == "" ]
  do
  selection=`dialog  --no-cancel --inputbox "Please select a drive to formart:\n $(ls /dev | sed s"/\n/\n/"g | grep sd[[:alpha:]]$ && ls /dev | sed s"/\n/\n/"g | grep hd[[:alpha:]]$)" $WINY $WINX 3>&1 1>&2 2>&3`
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
}

#write summary
function sum_all_up ()
{
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
}
#NOW WORK

#Format drive, enable SWAP, mount data drive
function apply_parts ()
{
  echo "Creating File system..."
  mkfs.$FILESYSTEM $DATAPART 	#FORMAT DATA-PART
  mount $DATAPART /mnt		#mount DATA-PART
  echo "Creating SWAP..."
  mkswap $SWAPPART		#Create SWAP part
  swapon $SWAPPART		#Enable SWAP
  echo "Partitioning Compleate!"
}


function software_setup ()
{
  dialog  --textbox txt/soft.en $WINY $WINX

  #PACSTRAP

  PACKS="base base-devel"			#Change this if needed
  PACKAGES="git ncurses tree dialog"	#Change this if needed

  pacstrap /mnt $PACKS $PACKAGES
}

function conf_file_setup ()
{
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
}
#Kernel Image
function ramdisk_create ()
{
  dialog   --yesno "Do you want to edit the Kernel image configuration file? (advanced mode)" $WINY $WINX

  if [ "$?" == "0" ]
  then
  nano /mnt/etc/mkinitcpio.conf
  fi

  #Generate image

  arch-chroot /mnt mkinitcpio -p linux
}

function keymap_save ()
{
  #Save Keymap

  echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
}
function set_root_key ()
{
  #root password

  dialog  --textbox txt/pass.en $WINY $WINX

  arch-chroot /mnt "passwd"
}

function syslinux_setup ()
{
  #Syslinux
  arch-chroot /mnt pacman-db-upgrade #fixes bug
  arch-chroot /mnt pacman -S syslinux
  arch-chroot /mnt syslinux-install_update -i -a -m
}

function finish_base_install ()
{
  #Set network

  if [ "$NETWORK" == "LAN" ]
  then
  arch-chroot /mnt systemctl enable dhcpcd
  fi

  rm -r config/* #clean config path
  pacman -Sy
  pacman -S git #needed for next step

  git clone http://github.com/jetspace/config

  bash config/syslinux/install.sh $DATAPART

  dialog  --textbox txt/done.en $WINY $WINX

  #UNMOUNT

  unmount /mnt
}

function reboot_install_disk ()
{
  #Reboot
  reboot
}

########################
# Params:
#  --module-cli will launch a simple debug promt, to test single modules
#  --perform (default) will perform a automated install
#  --about show some about infos
########################

#Functions for params

function module-cli ()
{
  #Display the user an interactive shell, to call the different Modules
  while [ "1" == "1" ]
  do
    read -p ">> " COMMAND
    $COMMAND
  done
}

function list_modules ()
{
  # List all supported modules
  echo -e "$MODULES"
}

function perform_full_setup ()
{
    license_dialog
    get_keymap
    network_setup
    disk_part
    sum_all_up
    apply_parts
    software_setup
    conf_file_setup
    ramdisk_create
    keymap_save
    set_root_key
    syslinux_setup
    finish_base_install
    reboot_install_disk
    echo "You should not see this :)"

}

function about ()
{
  echo -e "JetSpace (ARCH) Install script\n->EXPERIMENTAL<-\nIncluding:\n$MODULES"
}



if [ "$1" == "--module-cli" ]
  then
    module-cli
elif [ "$1" == "--perform" ]
  then
    perform_full_setup
elif [ "$1" == "--about" ]
  then
    about
else
    perform_full_setup
  fi
