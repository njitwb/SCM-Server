#声明伪目标，防止Makefile去生成all等
.PHONY := all install clean

#定义路径变量
TOPDIR     := $(shell pwd)
SRCDIR     := $(TOPDIR)/src
OBJECTDIR  := $(TOPDIR)/out

#定义编译器
CC         := gcc

#目标名称
TARGETMAIN    := SCMServer

#所有源码文件的路径被放入SOURCEDIRS，所有.c源码文件（含路径）放入SOURCES
VPATH         := $(shell ls -AxR $(SRCDIR)|grep ":"|tr -d ':')
SOURCEDIRS    := $(VPATH)
SOURCES       := $(foreach subdir,$(SOURCEDIRS),$(wildcard $(subdir)/*.c))

#所有目标文件.o（含路径）放入BUILDOBJS，注意它们的路径已经是build了。
SRCOBJS       := $(patsubst %.c,%.o,$(SOURCES))
BUILDOBJS     := $(subst $(SRCDIR),$(OBJECTDIR),$(SRCOBJS))

#包含头文件路径和编译选项
CFLAGS    := -O2 $(foreach dir,$(SOURCEDIRS),-I$(dir))
CFLAGS    += -I/usr/lib/perl/5.18/CORE

#defaut target:compile the currrent dir file and sub dir
all:$(TARGETMAIN)

$(TARGETMAIN) :$(BUILDOBJS)
	@echo [LINK] $^
	@$(CC) $^ $(CFLAGS) -o $@

#这里是Makefile的核心，根据%中的内容，查找src路径下对应的.c，注意到$@和$<自动
#变量的取值，首先查看路径build/xx是否存在，不存在则创建，然后我们尝试将$@中的src
#替换为build，这样所有的.o都将被创建到对应的build下了。
$(OBJECTDIR)%.o: $(SRCDIR)%.c
	@echo [CC] $^
	@[ ! -d $(dir $(subst $(SRCDIR),$(OBJECTDIR),$@)) ] & mkdir -p $(dir $(subst $(SRCDIR),$(OBJECTDIR),$@))
	@$(CC) $(CFLAGS) -o $(subst $(SRCDIR),$(OBJECTDIR),$@) -c $<
#添加安装的路径
intall:

clean:
	@find $(OBJECTDIR) -name "*.o" -o -name "*.d" | xargs rm -f
	@rm -f $(TARGETMAIN)
