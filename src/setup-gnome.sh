#Creates a user
#Install VIPER themes, and set the numix icon pack
#
WINY="0"
WINX="0"


dialog --no-lines --textbox txt/theme.en $WINY $WINX

#Install Viper Gnome Shell
wget http://github.com/jetspace/viper-gnome-shell/archive/master.tar.gz
tar -xzf master.tar.gz
mkdir /usr/share/themes
mkdir /usr/share/themes/viper
cp viper-gnome-shell-master/* -r /usr/share/themes/viper/

#Install Viper GTK
wget http://github.com/jetspace/viper-gtk/archive/master.tar.gz
tar -xzf master.tar.gz
mkdir /usr/share/themes
mkdir /usr/share/themes/viper
cp viper-gtk-master/* -r /usr/share/themes/viper/

#Create User

#enable admin group wheel
cat /etc/sudoers | sed s/"# %wheel ALL=(ALL) ALL"/"%wheel ALL=(ALL) ALL"/ > /etc/sudoers

selection=""

while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --inputbox "Username for the new user:" $WINY $WINX 3>&1 1>&2 2>&3`
done
USERN="$selection"
selection=""


dialog --no-lines --yesno "Should the user have admin rights?" $WINY $WINX

if [ "$?" == 0 ]
then
ADMIN=",wheel"
fi

useradd -G "bin,disk,log$ADMIN" $USERN

USER="$USERN"

#Enable user themes
su $USER -c "gsettings set org.gnome.shell enabled-extensions "$(gsettings get org.gnome.shell enabled-extensions | sed s/"]"/", 'user-theme@gnome-shell-extensions.gcampax.github.com']"/)""
#Set shell theme
su $USER -c "gsettings set org.gnome.shell.extensions.user-theme name "viper""
#set gtk theme
su $USER -c "gsettings set org.gnome.desktop.interface gtk-theme "viper""

#Set User Password
passwd $USER
