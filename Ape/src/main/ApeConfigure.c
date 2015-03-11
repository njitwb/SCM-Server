#include "Ape.h"

int writeConfig(int fd, char *config, char *contents)
{
	int ret = 0;

    if(write(fd, config, strlen(config)) != strlen(config)) {
	    ret = -1;
	}
    if(write(fd, contents, strlen(contents)) != strlen(contents)) {
	    ret = -1;
	}
	if(write(fd, "\n", 1) != 1) {
	    ret = -1;
	}

	if(ret == -1) {
	    printf("ERROR: write %s%s\n", config, contents);
	}

	return ret;
}

int creatConfigFile(TaskAlarm *task)
{
    int fd;

	fd = creat(task->config.fileName, 0666);
	if(fd < 0) {
	    printf("Can not creat config file");
		 return -1;
	}

	//将task->config的内容写入task->config.filename文件中
	if(writeConfig(fd, "project.name=", task->config.project.name) == -1) {
        return -1;
	}

	if(writeConfig(fd, "project.manifest=", task->config.project.manifest) == -1) {
        return -1;
	}

	if(writeConfig(fd, "project.branch=", task->config.project.branch) == -1) {
        return -1;
	}

	if(writeConfig(fd, "review.url=", task->config.review.url) == -1) {
        return -1;
	}

	if(writeConfig(fd, "review.name=", task->config.review.name) == -1) {
        return -1;
	}

	if(writeConfig(fd, "compile.script=", task->config.compile.script) == -1) {
        return -1;
	}

	if(writeConfig(fd, "compile.version=", task->config.compile.version) == -1) {
        return -1;
	}

	if(writeConfig(fd, "compile.release=", task->config.compile.release) == -1) {
        return -1;
	}

	if(writeConfig(fd, "download.mask=", task->config.download.mask) == -1) {
        return -1;
	}

	if(writeConfig(fd, "ftp.server=", task->config.ftp.server) == -1) {
        return -1;
	}

	if(writeConfig(fd, "send.mail=", task->config.send.mail) == -1) {
        return -1;
	}

	close(fd);

	return 0;
}
