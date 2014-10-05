#!/bin/bash

KeyboardLayout()
{
  clear
  echo "Choose Keyboard Layout: (if you enter none or a false value, it will use US keys)"
  echo " 1> German  QWERTZ"
  echo " 2> English QWERTY"

  read -n 1 BUFFER

  if [ "$BUFFER" == "1" ]
  then
  KEYBOARD="de-latin1"
  elif [ "$BUFFER" == "2" ]
  then
  KEYBOARD="us"
  else
  KEYBOARD="us"
  fi
  loadkeys $KEYBOARD

}

PartDisk()
{
  clear
  echo "Please now Create 2 Partitions:"
  echo " > first : Bootable for Jetspace Data"
  echo " > second: a SWAP partition"
  echo "" #newline
  echo "NOTE: You can change this setup, but only when you know what you are doing!"
  echo "" #newline
  echo "If you are ready, press [ENTER] (This operation will delete ANYTHING on your disk!)"

  read -s

  echo "Please enter the Drive (normaly /dev/sda):"
  read DRIVE

  #Part the disk!
  cfdisk $DRIVE

  clear
  echo "Please enter the number of the Data Partition:"
  read -n 1 BUFFER

  DATAPART="$DRIVE$BUFFER"

  echo "Please enter the number of the SWAP Partition:"
  read -n 1 BUFFER

  SWAPPART="$DRIVE$BUFFER"

  clear

  echo "Your Configuration:"
  echo "DATA: $DATAPART"
  echo "SWAP: $SWAPPART"
  echo -e "\nCorrect? [y/n]"
  read -n 1 BUFFER

  if [ "$BUFFER" == "n" ]
  then
      echo "Installation Failed!, Please Restart Installer, your system will fail!"
      exit
  fi

  clear

  echo "Normaly JetSpace use a ext4 file system. Do you want to use a Custom file system? [y/n]"
  read -n 1 BUFFER

  if [ "$BUFFER" == "n" ]
  then
    mkfs.ext4 $DATAPART
  else
    echo "Please enter the file system type:"
    read BUFFER
    mkfs.$BUFFER $DATAPART
  fi

  mount $DATAPART /mnt

  echo "Now Creating SWAP Partition..."

  mkswap $SWAPPART
  swapon $SWAPPART

  echo "Partitioning Complete!"

}

NetworkCreate()
{
  clear
  echo "Now we will setup Network!"

  echo "Please choose your network type:" #only LAN supported :(
  echo " 1> LAN"
  read -n 1 NET

  if [ "$NET" == "1" ]
  then
  dhcpcd
  else
  dhcpcd
  fi


}

BaseSystem ()
{
  PACKS="base base-devel"
  PACKAGES="git ncurses tree"
  clear

  echo "Default Packages are: $PACKAGES"
  echo "Also the groups $PACKS would be installed!"
  echo "Please Note: the Desktop Enviroment will be installed later!"

  echo "now installing, but this maybe take some time, depending on your network speed..."

  pacstrap /mnt $PACKS $PACKAGES

  sleep 2

}

SystemSetup()
{
  genfstab -p /mnt >> /mnt/etc/fstab #generate FSTAB


  bash src/conf.sh $DATAPART $SWAPPART $KEYBOARD $NET

  #unmout

  umount /mnt

}


clear
cat src/logo.ascii
echo "A free Arch Based Distro"
echo "------------------------"
echo -e "\n\n" # New Lines

#Now tell the user how the installation will look like
echo "Installation Plan:"
echo " > Choose Keyboard Layout"
echo " > Part the Disk"
echo " > Mount Patitions"
echo " > Setup Internet"
echo " > Install BASE ARCH system"
echo " > Configure System"
echo " > Bootloaded Setup"
echo " -----Reboot-----"
echo " > Install Jetspace Stuff"

echo -e "\nPress [ENTER] to continue"
read -s

#Setup the Keys
KeyboardLayout

#Part Disk
PartDisk

#Network
NetworkCreate

#Pacstrap
BaseSystem

#Setup the System
SystemSetup

clear
cat src/logo.ascii
echo "A free Arch Based Distro"
echo "------------------------"
echo -e "\n\n" # New Lines

echo "The Base instalation is now done, system will reboot to continue installation, please remove the install disk!"
echo "[ENTER]"
read -s
reboot
