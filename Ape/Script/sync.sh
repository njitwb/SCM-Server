#!/bin/bash
       
PROJECT_NAME=$1
DOWNLOAD=$2
LOG_FILE=$3
fileName="$HOME/.apeconfig"

log()
{
	echo [`date +%H:%M:%S`]:$1
}

sync_all()
{
	if [ -f $fileName ];then
		dir_name=`grep 'project.name' $fileName | awk -F '=' '{print $2}'`
		manifest_url=`grep 'project.manifest' $fileName | awk -F '=' '{print $2}'`
		branch=`grep 'project.branch' $fileName | awk -F '=' '{print $2}'`
	else
		log "ERROR:Please run ape config"
		return
	fi
	{
		log "cd $dir_name"
		cd $dir_name
#		log "curl http://mirror.core.archermind.com/android/aosp/repo >repo"
#		curl http://mirror.core.archermind.com/android/aosp/repo >repo
#		log "chmod +x repo"
#		chmod +x repo
		log "repo init -u $manifest_url -b $branch"
		repo init -u $manifest_url -b $branch
		log "repo sync -j4"
		repo sync -j4
	} | tee -a $LOG_FILE
}

sync_change()
{
	{
		log "cd $PROJECT_NAME"
		cd $PROJECT_NAME
		log "$DOWNLOAD"
		$DOWNLOAD
	} | tee -a $LOG_FILE
}

if [ $PROJECT_NAME = "all" ];then
    LOG_FILE=$DOWNLOAD
    sync_all
else
    sync_change
fi
