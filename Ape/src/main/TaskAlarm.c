#include "Ape.h"

Status initTaskList(TaskList *L)
{
    //初始化链表
	L->head = L->tail = NULL;
	L->len = 0;
	return OK;
}

Status destoryList(TaskList *L)
{
    return OK;
}

void setCurTask(Task *p, TaskAlarm *t)
{
    (*p)->task = t;
}

Status createTaskNode(Task *p, TaskAlarm *t)
{
	//创建一个task链表的节点
	(*p) = (Task)malloc(sizeof(struct TaskNode));
	if((*p) == NULL) {
	    return ERROR;
	} else {
	    setCurTask(p, t);
	}

	return OK;
}

void freeNode(Task *p)
{
    free(*p);
	*p = NULL;
}

Position priorPos(TaskList L, Task p)
{
    Task ph;

	ph = L.head;
	if(ph == NULL || ph == L.tail || ph == p) {
	    return NULL;
	} else {
	    while(ph->next != p) {
		    ph = ph->next;
		}
	}

	return ph;
}

Position nextPos(TaskList L, Task p)
{
    if(L.head == NULL || p == NULL) {
	    return NULL;
	}

	return p->next;
}

void deleteTaskNode(TaskList *L, Task q)
{
	Task pp,pn;

	if(L->head != NULL) {
	    pp = priorPos(*L, q);
		pn = nextPos(*L, q);
		if(pp == NULL) {
		    L->head = pn;
		} else {
		   pp->next = pn; 
		}
		freeNode(&q);
	}
}

Status deleteTaskById(TaskList *L, int id)
{
    Task p;

	p = L->head;
	while(p != NULL) {
	    if(p->task->id == id) {
			deleteTaskNode(L, p);
		    return OK;
		}
		p = p->next;
	}

	return ERROR;
}

Status clearTaskList(TaskList *L)
{
    //清空任务链表
	Task p;
	int i;

	L->len = sizeTaskList(*L);
	for(i = 0; i < L->len; i++) {
	    p = L->head;
		L->head = p->next;
		L->len--;
		freeNode(&p);
	}
	L->head = L->tail = NULL;

	return OK;
}

Status insertFirst(TaskList *h, Task s)
{
    if(s == NULL) {
	    return ERROR;
	} else {
	    if(h->head == NULL) {
		    h->head = s;
			h->tail = s;
			s->next = NULL;
			h->len = 1;
		} else {
		    s->next = h->head;
			h->head = s;
			h->len++;
		}
	}

	return OK;
}

Status deleteFirst(TaskList *h, Task *q)
{
    Task p;

	p = h->head;
	if(p = NULL) {
	    return ERROR;
	} else {
	    (*q) = p;
		h->head = p->next;
		if(h->head == NULL) {
		    h->tail = NULL;
		}
		freeNode(&p);
		h->len--;
	}

	return OK;
}

Status deleteTail(TaskList *L, Task *q)
{
    Task ph, pt;

	ph = L->head;
	pt = L->tail;
	if(ph == NULL) {
	    return ERROR;
	} else {
	    (*q) = pt;
		if(ph == pt) {
		    L->head = L->tail = NULL;
			L->len = 0;
		} else {
		    ph = priorPos(*L, pt);
			L->tail = ph;
			L->tail->next = NULL;
			L->len--;
		}
		freeNode(&pt);
	}

	return OK;
}

int sizeTaskList(TaskList L)
{
    //返回链表长度
	//即任务个数
	int len;
	Task p;

	len = 0;
	p = L.head;
	while(p != NULL) {
	    len++;
		p = p->next;
	}

	return len;
}

Bool isEmptyList(TaskList L)
{
    //检查任务链表是否为空，为空返回TRUE，否则返回FALSE
	if(L.head == NULL) {
	    return TRUE;
	} else {
	    return FALSE;
	}
}

Bool isExsitTaskByName(TaskList *L, Task q)
{
    //根据task的名字进行判断列表中是否存在该元素，存在返回TRUE，否则返回FALSE
	Task p;

	p = L->head;
	while(p != NULL) {
	    if(0 == strcmp(p->task->name, q->task->name)) {
		    return TRUE;
		}
	}

	return FALSE;
}

//遍历节点并调用visit方法
Status taskListTraverse(TaskList L, Status (*visit)(Task))
{
    Task p;

	p = L.head;
	while(p != NULL) {
	    if(visit(p) == ERROR) {
		    return ERROR;
		} else {
		    p = p->next;
		}
	}

	return OK;
}

Status checkAlarmTask(Task task)
{
    time_t t;
	struct tm *localtm;
	int week;

	t = time(NULL);
    localtm = localtime(&t);
    week = localtm->tm_wday;
    t = localtm->tm_hour * 3600 + localtm->tm_min * 60 + localtm->tm_sec;
	
	
    
}
