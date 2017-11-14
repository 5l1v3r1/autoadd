#!/bin/bash
# Version 2.0
# Change log: added auto mailing and.. less lines. \(^-^)/

# Usage: put usernames in a file, line by line.
# For auto mailing, download the python mailing script @ www.leonvoerman.nl
# For auto mailing, write <username>:<email> in a file. Example: leon:mail@leonvoerman.nl

function pause() {
	read -sn 1 -p "Press any key to continue..."
	echo ""
}

function checkroot {
if [ $USER == "root" ]; then
		echo -e "		Welcome, \e[1;31m$USER\e[0m"
		checkpwgen
else
	echo -e "\e[1;35m[ ERROR ]\e[0m Must run as \e[1;35mroot\e[0m!"; break 2
fi
}

function checkpwgen {
	if [ $(dpkg-query -W -f='${Status}' pwgen 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		echo -e "\e[1;35m[ MISSING ]\e[0m package pwgen - do you wish to install it now? (y/n)"; read _yn
		if [[ $_yn =~ ^[Yy]$ ]]; then
			echo -e "\e[1;33m[ INSTALLING ] pwgen"
			sleep 1s
			sudo apt-get install pwgen -y
			echo -e "\e[1;33m[ DONE ] pwgen\e[0m"
			sleep 1s; clear; menu
		else
			echo -e "\n\e[1;35m[ ERROR ]\e[0m Maybe next time..."
		fi
	else
		sleep 1s; clear; menu
	fi
}

function add_usr_file {
	# Create password directory
	if [ ! -d /home/passwords ]; then
		mkdir /home/passwords
		echo -e "\e[1;35m[ + ]\e[0m Created /home/passwords"; echo ""
	fi

	printf 'Usernames file location: '; read _location

	# Create users
	filename=$_location
	filelines=`cat $filename`
	for line in $filelines ; do
		useradd $line -m; echo -e "\e[1;35m[ + ]\e[0m Added user: $line"
		echo -e "\e[1;35m	[ + ]\e[0mUser directory: /home/$line"
		#mkdir /home/$line
		#chown -R $line:$line /home/$line # Give permission to user
		pwgen 8 1 >> /home/passwords/$line; echo -e "\e[1;35m	[ + ]\e[0mPassword stored in: /home/passwords/$line" # Generate password

		_password=`cat "/home/passwords/$line"` # Read password
		echo $line:$_password | chpasswd # Set password
	done

	pause; clear; menu
}

function mailing {
	# Create password directory
	if [ ! -d /home/passwords ]; then
		mkdir /home/passwords
		echo -e "\e[1;35m[ + ]\e[0m Created /home/passwords"; echo ""
	fi

	if [ ! -f newaccountmail.py ]; then
		echo -e "\e[1;35m[ MISSING ]\e[0m Could not find newaccountmail.py for mailing!"
	fi

	printf 'Username list location: '; read _location

	filename=$_location
	filelines=`cut -d':' -f1 $filename` # only usernames
	_emailz=`cut -d':' -f2 $filename` # <<-- With a Z, so leet!
	_counter="1"
	_total="1"
	_p="p" # <<-- Yes, I know.. (It's a workaround)

	echo "$_emailz" >> mailz # Create file with the Email addresses only

	# Create users
	for line in $filelines; do
		let _total=_total+1

		while [ $_counter -lt $_total ]; do
			_username=$line
			useradd $_username; echo -e "\e[1;35m[ + ]\e[0m Added user: $_username"
			mkdir /home/$_username; echo -e "\e[1;35m	[ + ]\e[0mUser directory: /home/$_username"
			chown -R $_username:$_username /home/$_username # Give permission to user
			pwgen 8 1 >> /home/passwords/$_username; echo -e "\e[1;35m	[ + ]\e[0mPassword stored in: /home/passwords/$_username" # Generate password
			_password=`cat "/home/passwords/$_username"` # Read password
			echo $_username:$_password | chpasswd # Set password
			_email=`sed -n $_counter$_p mailz` # Read Email address
			python newaccountmail.py $_username $_password $_email; echo -e "\e[1;35m	[ + ]\e[0mDetails sent to: $_email" # Send Email
			let _counter=_counter+1
		done
	done
	rm mailz # File no longer needed - delete it
	pause; clear; menu
}


function del_usr_file {
	printf 'File location: '; read _location

	# Delete users
	filename=$_location
	filelines=`cut -d':' -f1 $filename` # only usernames
	for line in $filelines ; do
		userdel $line; echo -e "\e[1;35m[ - ]\e[0m $line"; rm -rf /home/$line; rm /home/passwords/$line
	done

	pause; clear; menu
}

# Menu starts here
function menu {
	echo ""
	echo -e "\e[33m		####### Version: 2.0 #######\e[0m"
	echo ""
	_menu_items=("Add users in file" "Add users with mailing" "Delete users in file" "Quit")
	select menu in "${_menu_items[@]}"
	do
		case $menu in
			"Add users in file") clear; add_usr_file; break
			;;
			"Add users with mailing") clear; mailing; break
			;;
			"Delete users in file") clear; del_usr_file; break
			;;
			"Quit") clear; echo -e "		Goodbye, \e[1;31m$USER\e[0m"; sleep 1s; break 2
			;;
			*) echo -e "\e[1;35m[ ! ]\e[0m Not a valid selection!"; sleep 1s; clear; menu; break
		esac
	done
}

clear; checkroot
