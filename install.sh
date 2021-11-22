#!/bin/bash
# Install script to setup the minecraft docker server, needs to be run as root or with sudo.

minecraftDir="/opt/minecraft"

function install() {
	echo "Installing the Minecraft docker server."
	repoPath=$(dirname $0)

	if [[ ! $(getent group minecraft) ]]; then
		echo "Minecraft group didn't exist, adding them"
		groupadd --gid 1003 minecraft
	fi

	if [[ ! $(getent passwd minecraft) ]]; then
		echo "Minecraft user didn't exist, adding them"
		useradd -mg minecraft --uid 1003 minecraft
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
		cp $repoPath/backup.sh $minecraftDir
		sed -i "s|<MINECRAFT_DIR>|${minecraftDir}|g" $minecraftDir/backup.sh	
	fi

	# Chown at the end after we have moved everything into the correct place
	if [ -d $minecraftDir ]; then
		chown minecraft:minecraft -R $minecraftDir
	fi
	# The cron job will need to be setup under user minecraft for secuerity


}

function uninstall() {
	echo "Remove stuff set in the install"
}

function verifyServer() {
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
		if [[ -a $minecraftDir/docker-compose.yml ]]; then
			echo "docker compose exists"
		fi
		# Check if the data dir exists
		if [[ -d $minecraftDir/data ]]; then
			echo "data dir exists"
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
else
	echo "Operation not reconized, use install, uninstall, or verify."
fi
