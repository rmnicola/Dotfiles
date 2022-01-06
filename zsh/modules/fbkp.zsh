# Check env variable for gnome backup
# If it does not exist, send bk home
if [[ ! $FIREFOX_BACKUP_DIR ]]; then fbk_folder=$HOME/.mozillabkp
else fbk_folder=$FIREFOX_BACKUP_DIR
fi

fbkp () {
	bkp_command="$1"
	if [ $# -eq 0 ]; then fbkp_help;

	# bkp commands
	elif [ $bkp_command = push ]; then _fpush $@
	elif [ $bkp_command = pull ]; then _fpull $@
	else fbkp_help 

	fi
}

fbkp_help () {
	printf "Usage:\n\tfbkp <push/pull>\n"
}

_fpush () {
	if [[ ! -d $HOME/.mozilla ]]; then
		echo "!! Nothing to push. Exiting."
		return
	fi
	echo ">> Dumping: Mozilla folder."
	rsync -av $HOME/.mozilla/ $fbk_folder
	if [ $? -eq 0 ]; then echo "Dumped: Mozilla folder."
	else echo "!! Failed to dump Mozilla folder."; fi
}

_fpull () {
	if [[ ! -d $fbk_folder ]]; then
		echo "!! Nothing to pull. Exiting."
		return
	fi
	echo ">> Loading: Mozilla folder."
	rsync -av $fbk_folder/ $HOME/.mozilla 
	if [ $? -eq 0 ]; then echo "Loaded: Mozilla folder."
	else echo "!! Failed to load Mozilla folder."; fi
}

compctl -k "(push pull help)" fbkp
