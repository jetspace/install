#!/bin/bash

#This file configures the system in chroot mode


Config ()
{
  clear
  echo "Please Enter a Hostname for this Computer:"
  read HOSTNAME

  echo $HOSTNAME > /mnt/etc/hostname

  echo "Please Choose a Loacle Setting:"
  echo " 1> German"
  echo " 2> English (US)"
  echo " 3> English (GB)"
  echo " 4> Custom"
  read -n 1 BUFFER

  if [ "$BUFFER" == "1" ]
  then
  LOCALE="de_DE.utf8"
  elif [ "$BUFFER" == "2" ]
    LOCALE="en_US.utf8"
  elif [ "$BUFFER" == "3" ]
      LOCALE="en_GB.utf8"
  elif [ "$BUFFER" == "4" ]
      echo "Enter Locale: (language_COUNTRY.utf8 for example: en_US.utf8)"
      read LOCALE
  fi

  #Set Locale:

  echo "export LC_DATE=$LOCALE" > /mnt/etc/locale.conf
  echo "export LC_NUMERIC=$LOCALE" >> /mnt/etc/locale.conf
  echo "export LC_TIME=$LOCALE" >> /mnt/etc/locale.conf
  echo "export LANG=$LOCALE" >> /mnt/etc/locale.conf

  echo "Setted Locale Succesfully!"

  echo "Timezone Setup not implemented yet :("

  #------------------------------------------------------------
  #TODOTODOTODOTODO

  echo "using UTC..."

  #just link UTC

  arch-chroot /mnt "ln /usr/share/zoneinfo/UTC /etc/localtime"
  #TODOTODOTODOTODO
  #------------------------------------------------------------

  echo "Please now remove the '#' before the locals you need:"
  echo "Normaly you should use the language of your country, so"
  echo "for germany: de_DE.UTF-8 UTF-8"
  echo "for Great Brittain: en_GB.UTF-8 UTF-8"
  echo "when done, save the file with [CTRL]+[O] and"
  echo "Exit the Editor with [CTRL]+[X]."
  echo "" #newline
  echo "[ENTER]"
  read -s
  nano /mnt/etc/locale.gen

  arch-chroot /mnt "locale-gen"


  clear

  echo "Now, we need to configure the Kernel Image."
  echo "You can use the default Kernel Configuration of ARCH Linux"
  echo "or edit the mkinitcpio.conf file."
  echo "" #newline

  echo "Would you like to edit the file? [y/n]"

  read -n 1 BUFFER

  if [ "$BUFFER" == "y" ]
  then
    nano /mnt/etc/mkinitcpio.conf
  fi

  arch-chroot /mnt "mkinitcpio -p linux"

  echo "Kernel Image generation done!"

  echo "Now configuring the root password"
  echo "this must be very safe, because with this you"
  echo "can do ANYTHING on your computer..."
  arch-chroot /mnt "passwd"


  echo "now setting up keymap..."

  echo $KEYBOARD > /mnt/etc/vconsole.conf

}


SysLinuxSetup()
{
  echo "now installing SysLinux Bootloader [y/n]"

  read -n 1 BUFFER

  if [ "$BUFFER" == "y" ]
  then
    arch-chroot /mnt "pacman -S syslinux"
    echo "Download Complete!"
    arch-chroot /mnt "syslinux-install_update -i -a -m"
    clear
    echo "Bootloader Install done!"
    echo "Please Check the Config file of the bootloader, especially for the 'root' line!"
    echo "$(cat /boot/syslinux/syslinux.cfg | grep root=) must be correct!"
    echo "[ENTER]"

    read -s

    nano /mnt/boot/syslinux/syslinux.cfg
  else
    echo "No Bootloader Installed"
  fi




}


#get previus vars
DATAPART=$1
SWAPPART=$2
KEYBOARD=$3
NETWORK=$4


cat src/logo.ascii
echo "A free Arch Based Distro"
echo "------------------------"
echo -e "\n\n" # New Lines

echo "Installer Reloaded for the second of three steps"
echo "[ENTER]"

read -s

#Conifgure base settings
Config

#Bootloader
SysLinuxSetup


#Now Exit Chroot
exit
