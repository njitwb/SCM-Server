#ifndef __TASKALARM_H_
#define __TASKALARM_H__

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>  
#include <sys/stat.h>  
#include <arpa/inet.h>  
#include <time.h>
#include <stdlib.h>

#define TRUE  1
#define FALSE  0
#define OK  1
#define ERROR  0
#define INFEASIBLE  -1
#define OVERFLOW  -2

typedef int Status;
typedef char Bool;

//Config文件的子项
typedef struct {
    char *name;   //project.name,项目的名称 例如:intel_byt_i_64
    char *manifest;    //project.manifest manifest文件的存放地址,例如:ssh://10.20.25.93:29418/intel_byt_i_64/manifests
	char *branch;    //project.branch,例如:dev_branch
} Config_project;

typedef struct {
    char *url;    //review.url,代码审核的地址,例如:http://10.20.25.93:8081
	char *name;    //review人的姓名
} Config_review;

typedef struct {
    char *script;    //编译脚本的文件名
	char *version;    //编译选项,执行lunch时使用,例如:byt_crb_64-eng
	char *release;    //release时的文件夹名称
} Config_compile;

typedef struct {
    char *mask;    //编译时屏蔽掉的changID
} Config_download;

typedef struct {
    char *server;    //FTP服务器目录
} Config_ftp;

typedef struct {
    char *mail;    //编译完成后将自动发送邮件
} Config_send;

//编译任务的配置结构体,在创建任务时填充
typedef struct {
	char *fileName;    //config文件名
    Config_project project;
	Config_review review;
    Config_compile compile;
	Config_download download;
	Config_ftp ftp;
	Config_send send;
}TaskConfig;

typedef struct {
    Bool alarm_week[7];  //定时执行的周数 
    time_t alarm_t;    //定时执行的时间，相对于当天0时0分0秒的秒数
	struct tm alarm_tm;    //定时执行的时间结构体
    TaskConfig config;    //任务的配置
    int id;    //任务ID
	Status status;    //任务状态
	char *name;
} TaskAlarm;

//任务链表节点结构体
typedef struct TaskNode {
   TaskAlarm *task;
   struct TaskNode *next;
} TaskNode, *Task, *Position;

//链表类型
typedef struct {
    Task head, tail;    //分别指向任务链表的头和尾
	int len;    //链表中元素的个数
}TaskList;

int createConfigFile(TaskAlarm *task);

#endif
