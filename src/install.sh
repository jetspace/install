#!/bin/bash

KeyboardLayout()
{
  clear
  echo "Choose Keyboard Layout: (if you enter none or a false value, it will use US keys)"
  echo " 1> German  QWERTZ"
  echo " 2> English QWERTY"

  read $BUFFER -n 1

  if [ "$BUFFER" == "1" ]
  then
  KEYBORAD="loadkeys de-latin1"
  elif [ "$BUFFER" == "2" ]
  then
  KEYBORAD="loadkeys us"
  else
  KEYBOARD="loadkeys us"
  fi
  loadkeys $KEYBOARD

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


#
