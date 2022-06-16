#!/bin/bash
# Install script to setup the minecraft docker server, needs to be run as root or with sudo.

minecraftDir="/opt/minecraft"

# Setups host components of minecraft docker server
function install() {
	echo "Installing the Minecraft docker server."
	repoPath=$(dirname $0)
	# Create minecraft user and group
	if [[ ! $(getent group minecraft) ]]; then
		echo "Minecraft group didn't exist, adding them"
		groupadd --gid 1003 minecraft
	fi
	if [[ ! $(getent passwd minecraft) ]]; then
		echo "Minecraft user didn't exist, adding them"
		useradd -Mg minecraft --uid 1003 minecraft
	fi
	# setup minecraft directory in /opt
	if [ ! -d $minecraftDir ]; then
		echo "Server location didn't exist, creating it at $minecraftDir"
		mkdir -p $minecraftDir/data
		mkdir $minecraft/worldBackup
		chown minecraft:minecraft -R $minecraftDir
	fi

	# Copy the docker-compose file to the new directory
	if [[ ! -f $minecraftDir/docker-compose.yml ]]; then
		cp $repoPath/docker-compose.yml $minecraftDir
		sed -i "s|<MINECRAFT_DIR>|${minecraftDir}|g" $minecraftDir/docker-compose.yml
	fi
	#Setup system.d file
	if [[ ! -f /etc/systemd/system/minecraft.service ]]; then
		echo "Minecraft systemd file didn't exist, creating it."
		cp $repoPath/minecraft.service /etc/systemd/system/
		sed -i "s|<MINECRAFT_DIR>|${minecraftDir}|g" /etc/systemd/system/minecraft.service
		systemctl daemon-reload
	fi
	# Setup world backup using cronjob
	if [[ ! -f $minecraftDir/backup.sh ]]; then
		# The cron job will need to be setup under user minecraft for security
		cp $repoPath/backup.sh $minecraftDir
		sed -i "s|<MINECRAFT_DIR>|${minecraftDir}|g" $minecraftDir/backup.sh
		# TODO Need to add the cronjob as the minecraft user, find out how to do that in a script.
	fi
	# Chown at the end after we have moved everything into the correct place
	if [ -d $minecraftDir ]; then
		chown minecraft:minecraft -R $minecraftDir
	fi
}

function uninstall() {
	if [[ -f /etc/systemd/system/minecraft.service ]]; then
		rm /etc/systemd/system/minecraft.service
	fi
	# TODO Need to finish the rest of the uninstall
}

function verifyServer() {
	echo "Verifying install of minecraft server"
	# Check group exists
	returnCode=0
	if [[ ! $(getent group minecraft) ]]; then
		echo "Minecraft group doesn't exist."
		returnCode=-1
	fi
	# Check user exists
	if [[ ! $(getent passwd minecraft) ]]; then
		echo "Minecraft user doesn't exist"
		returnCode=-1
	fi
	# Check directories
	if [ -d $minecraftDir ]; then
		# Check if the docker-compose file is here
		if [[ ! -a $minecraftDir/docker-compose.yml ]]; then
			echo "docker compose doesn't exist"
			returnCode=-1
		fi
		# Check if the data dir exists
		if [[ ! -d $minecraftDir/data ]]; then
			echo "data dir doesn't exist"
			returnCode=-1
		fi
	else
		echo "$minecraftDir dosn't exist"
		returnCode=-1
	fi
	# Check if minecraft systemd file exists
	if [[ ! -a /etc/systemd/system/minecraft.service ]]; then
		echo "systemctl service doesn't exist"
		returnCode=-1
	fi

	if [[ $returnCode -eq 0 ]]; then
		echo "Nothing wrong with minecraft install"
	else
		echo "Something wrong with minecraft install"
	fi
	return $returnCode
}


while getopts s:d: flag
do
	case "${flag}" in
		s) operation=${OPTARG};;
		d) directory=${OPTARG};;
	esac
done

if [[ -z $operation ]]; then
	echo "No operation passed in: $ ./install.sh -s <install|unistall|verify> -d <path>"
	exit 0
fi

if [[ -n $directory ]]; then
	minecraftDir=$directory
else
	echo "No directory passed in, using path $minecraftDir"
fi

# check if the operation is install, uninstall, or verify
if [[ $operation = "install" ]]; then
	install $directory
elif [[ $operation = "unstall" ]]; then
	uninstall $directory
elif [[ $operation = "verify" ]]; then
	verifyServer $directory
	exit $?
else
	echo "Operation not reconized, use install, uninstall, or verify."
fi
