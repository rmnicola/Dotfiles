bk_folder=$HOME/'Documents/5 - Backup'

if [[ ! -d $bk_folder ]]; then bk_folder=$HOME; fi

fbkp () {
	bkp_command="$1"
	if [ $# -eq 0 ]; then help;

	# bkp commands
	elif [ $bkp_command = push ]; then _fpush $@
	elif [ $bkp_command = pull ]; then _fpull $@
	else help 

	fi
}

help () {
	printf "Usage:\n\tfbkp <push/pull>\n"
}

_fpush () {
	if [[ ! -d $HOME/.mozilla ]]; then
		echo "!! Nothing to push. Exiting."
		exit
	fi
	echo ">> Dumping: Mozilla folder."
	cp -rf $HOME/.mozilla $bk_folder/Mozilla
	if [ $? -eq 0 ]; then echo "Dumped: Mozilla folder."
	else echo "!! Failed to dump Mozilla folder."; fi
}

_fpull () {
	if [[ ! -d $bk_folder/Mozilla ]]; then
		echo "!! Nothing to pull. Exiting."
		exit
	fi
	echo ">> Loading: Mozilla folder."
	cp -rf $bk_folder/Mozilla $HOME/.mozilla 
	if [ $? -eq 0 ]; then echo "Loaded: Mozilla folder."
	else echo "!! Failed to load Mozilla folder."; fi
}

compctl -k "(push pull help)" fbkp
