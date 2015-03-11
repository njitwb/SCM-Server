#!/bin/bash

LOG_FILE=$1
IMAGE_DIR=$2
fileName="$HOME/.apeconfig"

log()
{
        echo [`date +%H:%M:%S`]:$1
}

function compile()
{
	if [ -f $fileName ];then
		project_name=`grep 'project.name' $fileName | awk -F '=' '{print $2}'`
		compile_version=`grep 'compile.version' $fileName | awk -F '=' '{print $2}'`
		compile_tool=`grep 'compile.tool' $fileName | awk -F '=' '{print $2}'`
	else
		log "ERROR:Please run ape config"
		return
	fi
	{
		log "cd $project_name"
		cd $project_name
		if [ $compile_tool = defualt  ];then
			log "source build/envsetup.sh"
			source build/envsetup.sh
			log "lunch $compile_version"
			lunch $compile_version
			log "update api"
			make update-api
			log "make flashfiles -j16"
			make flashfiles -j16
		else
			log "use user's compile tool"
			$compile_tool $compile_version
		fi
		version=`echo $compile_version | awk -F '-' '{print $2}'`
		log "cp out/target/product/byt_m_crb/live.img $IMAGE_DIR/live-$version.img"
		cp out/target/product/byt_m_crb/live.img $IMAGE_DIR/live-$version.img
	} | tee -a $LOG_FILE
}

compile
