# Check env variable for gnome backup
# If it does not exist, send bk home
if [[ ! $GNOME_BACKUP_DIR ]]; then gbk_folder=$HOME/.gnomebkp
else gbk_folder=$GNOME_BACKUP_DIR
fi

systems=("nautilus" \
	"desktop" \
	"shell" \
	"system" \
	"terminal")


gbkp () {
	bkp_command="$1"
	if [ $# -eq 0 ]; then gbkp_help;

	# bkp commands
	elif [ $bkp_command = push ]; then _dpush $@
	elif [ $bkp_command = pull ]; then _dpull $@
	else gbkp_help 

	fi
}

gbkp_help () {
	printf "Usage:\n\tgbkp <push/pull>\n"
}

_dpush () {
	for s in ${systems[@]}; do
		echo ">> Dumping: $s."
		touch $gbk_folder/"$s-bkp"
		dconf dump /org/gnome/$s/ > $gbk_folder/"$s-bkp"
		if [ $? -eq 0 ]; then echo ">> Dumped: $s."
		else echo "!! Failed to dump: $s."; fi
	done
}

_dpull () {
	for s in ${systems[@]}; do
		echo ">> Loading: $s."
		dconf load /org/gnome/$s/ < $gbk_folder/"$s-bkp"
		if [ $? -eq 0 ]; then echo ">> Loaded: $s."
		else echo "!! Failed to load: $s."; fi
	done
}

compctl -k "(help pull push)" gbkp

