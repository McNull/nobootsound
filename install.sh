#!/bin/bash
#
# Install the script by moving the two script files 
# to the user home directory ~ (hiding them with a dot .)
# and then hooking them to the login and logout
#

if [ "$(id -u)" != "0" ]; then
	echo "You need administrative privileges to install this script.\nPlease run\nsudo sh install.sh"
	exit 1
fi

ACTUAL_USER=$(sudo stat -f '%Su' ~)

uninstallmode=false

while getopts ":u" opt; do
  case $opt in
    u)
		uninstallmode=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


if [ "$uninstallmode" = true ]; then
	echo "Removing hooks..."
	defaults delete com.apple.loginwindow LoginHook
	defaults delete com.apple.loginwindow LogoutHook
	
	echo "Removing files..."
	rm ~/bin/nobootsound/.nobootsound_loginhook
	rm ~/bin/nobootsound/.nobootsound_logouthook
	rm ~/bin/nobootsound/.nobootsound_logoutvol
	
else
	echo "Copying files..."
	# Create file .nobootsound_logoutvol where the mute state is stored
	sudo -u $ACTUAL_USER touch ~/bin/nobootsound/.nobootsound_logoutvol
	sudo -u $ACTUAL_USER echo "false" > ~/bin/nobootsound/.nobootsound_logoutvol
	
	# Copy login and logout scripts and make them executable
	sudo -u $ACTUAL_USER cp nobootsound_loginhook ~/bin/nobootsound/.nobootsound_loginhook
	sudo -u $ACTUAL_USER cp nobootsound_logouthook ~/bin/nobootsound/.nobootsound_logouthook
	sudo -u $ACTUAL_USER chmod +x ~/bin/nobootsound/.nobootsound_loginhook
	sudo -u $ACTUAL_USER chmod +x ~/bin/nobootsound/.nobootsound_logouthook

	echo "Registering hooks..."
	# Register the scripts as login and logout hooks
	defaults write com.apple.loginwindow LoginHook  ~/bin/nobootsound/.nobootsound_loginhook
	defaults write com.apple.loginwindow LogoutHook ~/bin/nobootsound/.nobootsound_logouthook

	echo "Done!"
fi