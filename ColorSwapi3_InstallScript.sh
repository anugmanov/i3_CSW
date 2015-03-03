#!/bin/bash
#-------------------------------
#AUTHOR:__nugman
#2015/03/01
#-------------------------------
#Color Swap for i3 InstallScript
#Works from anywhere
#works with ~/.i3 directory
#Needs i3WM and its config file in the path below.
#(!!!) IT IS HIGHLY RECOMMENDED FOR YOU TO KEEP BACKUP OF YOUR I3 CONFIG FILE (!!!)
#------------------------------
#SUPPORTED CMD OPTIONS:
#-i install sequence
#-r refresh all files. Will use file named 'config' as main. Old files will be overwritten.
#-d delete all installed scripts and config files. Restores default i3 behavior.
#-----------------------------
PTH=${HOME}"/.i3/"

#Colors in HTML format here. Feel free to add any color in given format.
#Do not start and end with a newline
#------------------------
COLORS="FF0000
FF3300
CCFF00
00FF00
0000CC
9900FF
330066
FFFFFF
8B008B
7CFC00
800000
FFA500
FF4500
800080
663399
4169E1
00FF7F
4682B4"
#-------------------------

NCOL=$(echo "$COLORS" | wc -l) #NN of colors



install() {
	#install script here
	if [[ "$(i3 -C ${PTH}"config")"=='' ]]; then
		echo "Valid config file found. [OK]"
	else
		echo "NOT a valid i3 config file. [ERROR]"
	fi

	CURDIR=$(pwd)
	cd ${PTH}

	swapscript $PTH

	#Make backup of original config file
	cp config config.bkp
	EHOME=$(echo $HOME | sed -e "s/\//\\\\\//g") #/ -> \/
	
	#I have fucked my mind while producing the lines below
	cat config | sed -e "s/\$mod+Left focus left/\$mod+Left exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus left\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/\$mod+Down focus down/\$mod+Down exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus down\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/\$mod+Up focus up/\$mod+Up exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus up\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/\$mod+Right focus right/\$mod+Right exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus right\"/g" > config_tmp
	mv config_tmp config
	#And begin making config files
	I=1
	for COLOR in $COLORS; do
		cp config config${I}
		echo "Added config file $I"
		RESCOLOR="client.focused #${COLOR} #${COLOR} #ffffff #2e9ef4"
		echo -e "\n" >> config${I}
		echo "#Color Swap script-----" >>config${I}
		echo $RESCOLOR >> config${I}
		echo "#----------------------">>config${I}
		I=$((I+1))
	done
	echo "All configs added. Wait now..."
	#i3-msg reload

}

swapscript() {
	#generates swap script to $1 dir
	DESTDIR=$1

	CURDIR=$(pwd)
	cd $DESTDIR

	#Codeline here-----
	echo -e "#!/bin/bash
		#swap config files
		#to change colors

		NUMB=${NCOL} #NN of config files

		R=\$((RANDOM%NUMB + 1))

		if [[ \$R == \$NUMB ]]; then
			R=\$((R-1))
		fi

		cd ${HOME}/.i3
		NAME="config"\${R}
		mv config config_tmp
		mv \$NAME config
		mv config_tmp \$NAME
		i3-msg reload" > swap_colors.sh
		chmod +x swap_colors.sh

	#End subscript code
	cd $CURDIR
}

refresh() {
	#refresh script here
	cd $PTH
	#remove all old stuff
	rm config.bkp
	cp config config.bkp
	for(( i = 1;i<=$NCOL; i++)); do
		rm config${i}
	done
	#and install new
	install
}

delete() {
	#deletes all. 
	cd $PTH
	#remove all old stuff
	rm config
	mv config.bkp config
	for(( i = 1; i<=$NCOL; i++)); do
		rm config${i}
		echo "Removed config${i}. [OK]"
	done
	rm swap_colors.sh
	echo "All done. Will now refresh i3 config file"
	#i3-msg refresh
}

#main prog sequence here
case "$1" in
	"-i")
		install
		;;
	"-r")
		refresh
		;;
	"-d")
		delete
		;;
esac
