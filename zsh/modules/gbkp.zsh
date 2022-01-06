bk_folder=$HOME/'Documents/5 - Backup'

if [[ ! -d $bk_folder ]]; then bk_folder=$HOME; fi

systems=("nautilus" \
	"desktop" \
	"shell" \
	"system" \
	"terminal")


gbkp () {
	bkp_command="$1"
	if [ $# -eq 0 ]; then help;

	# bkp commands
	elif [ $bkp_command = push ]; then _dpush $@
	elif [ $bkp_command = pull ]; then _dpull $@
	else help 

	fi
}

help () {
	printf "Usage:\n\tgbkp <push/pull>\n"
}

_dpush () {
	for s in ${systems[@]}; do
		echo ">> Dumping: $s."
		touch $bk_folder/"$s-bkp"
		dconf dump /org/gnome/$s/ > $bk_folder/"$s-bkp"
		if [ $? -eq 0 ]; then echo ">> Dumped: $s."
		else echo "!! Failed to dump: $s."; fi
	done
}

_dpull () {
	for s in ${systems[@]}; do
		echo ">> Loading: $s."
		dconf load /org/gnome/$s/ < $bk_folder/"$s-bkp"
		if [ $? -eq 0 ]; then echo ">> Loaded: $s."
		else echo "!! Failed to load: $s."; fi
	done
}

compctl -k "(help pull push)" gbkp

