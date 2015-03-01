#!/bin/bash
#-------------------------------
#AUTHOR:__nugman
#2015/03/01
#-------------------------------
#Color Swap for i3 InstallScript
#Works from anywhere
#works with ~/.i3 directory
#Needs i3WM and its config file in the path below.
#------------------------------
#SUPPORTED CMD OPTIONS:
#-i install sequence
#-d delete all installed scripts and config files. Restore default i3 behavior.
#-----------------------------
PTH=${HOME}"/.i3/"
NCOL=18 #NN of colors

#Colors in HTML format here
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
	cat config | sed -e "s/focus left/exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus left\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/focus down/exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus down\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/focus up/exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus up\"/g" > config_tmp
	mv config_tmp config
	cat config | sed -e "s/focus right/exec --no-startup-id \"${EHOME}\/.i3\/swap_colors.sh \&\& i3-msg focus right\"/g" > config_tmp
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
	touch swap_configs.sh

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

	
install
