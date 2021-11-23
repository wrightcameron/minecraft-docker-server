#!/bin/bash
# Shell script to backup the minecraft world, it will create create a tar file,
# then keep 5 backups going back 5 days.
# If used with cronjob used `0 4 * * * <MINECRAFT_DIR>/backup.sh`
map='world'
backupDir='<MINECRAFT_DIR>/worldBackup'
tarName=$map-$(date +%d-%m-%Y).tar.gz

if [[ ! -d $backupDir ]]; then
    echo "Couldn't find $backupDir, so creating it."
    mkdir $backupDir
fi
cd $backupDir

if [[ -a ../data/$map ]]; then
    tar czvf $tarName ../data/$map &> /dev/null
    chown minecraft:minecraft $tarName
    # Remove worlds older than 5 days.
    find $backupDir/*.gz -mtime +5 -exec rm {} \;
else
    echo "The $map doesn't appear to exist in minecraft dir."
fi

