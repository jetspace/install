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

rm master.tar.gz

#Install Viper GTK
wget http://github.com/jetspace/viper-gtk/archive/master.tar.gz
tar -xzf master.tar.gz
mkdir /usr/share/themes
mkdir /usr/share/themes/viper
cp viper-gtk-master/* -r /usr/share/themes/viper/

rm master.tar.gz

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

while [ "$selection" == "" ]
do
selection=`dialog --no-lines --no-cancel --inputbox "Real Name of the user?:" $WINY $WINX 3>&1 1>&2 2>&3`
done
NA="$selection"
selection=""


dialog --no-lines --yesno "Should the user have admin rights?" $WINY $WINX

if [ "$?" == 0 ]
then
ADMIN=",wheel"
fi

useradd -c "$NA" -G "bin,disk,log$ADMIN" $USERN

USER="$USERN"

#Enable user themes
su $USER -c "dbus-launch --exit-with-session gsettings set org.gnome.shell enabled-extensions "[\'user-theme\@gnome-shell-extensions.gcampax.github.com\']" 2> /dev/null
#Set shell theme
su $USER -c "dbus-launch --exit-with-session gsettings set org.gnome.shell.extensions.user-theme name "viper"" 2> /dev/null
#set gtk theme
su $USER -c "dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface gtk-theme "viper"" 2> /dev/null

#Set User Password
passwd $USER
