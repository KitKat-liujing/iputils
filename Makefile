#
# Configuration　配置
#

# CC　指定gcc程序
CC=gcc
# Path to parent kernel include files directory　路径的父内核头文件目录
LIBC_INCLUDE=/usr/include
# Libraries　库
ADDLIB=
# Linker flags　连接标志
＃Wl选项告诉编译器将后面的参数传递给连接器
#-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接
#-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接
LDFLAG_STATIC=-Wl,-Bstatic　
＃－Wl，-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接
#指定加载库
LDFLAG_DYNAMIC=-Wl,-Bdynamic

LDFLAG_CAP=-lcap＃加载cap函数库
LDFLAG_GNUTLS=-lgnutls-openssl＃加载TLS加密函数库
LDFLAG_CRYPTO=-lcrypto＃srypto加密解密函数库
LDFLAG_IDN=-lidn  #idn恒等函数库
LDFLAG_RESOLV=-lresolv＃resolv函数库
LDFLAG_SYSFS=-lsysfs　＃sysfs接口函数库

#
# Options选项
#
#变量定义，设置开关
# Capability support (with libcap) [yes|static|no]　
＃cap函数库的支持，用libcap表示，状态分别是：是，静态，没有
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]　　
＃sysfs函数库的支持，用libsysfs-deprecated表示，状态分别是：没有，是，静态
USE_SYSFS=no
# IDN support (experimental) [no|yes|static]　
＃IDN函数库的支持，用experimental表示，状态分别为：没有，是，静态
USE_IDN=no　＃默认状态为第一个

# Do not use getifaddrs [no|yes|static]＃默认不使用getifaddrs函数获得接口的相关信息
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []　
＃arping默认设备，如网卡、以太网、无线
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]　
USE_GNUTLS=yes　＃默认GNU TLS库ping6的状态为：是
# Crypto library for ping6 [shared|static]　
USE_CRYPTO=shared　＃默认加密解密库ping6的状态为：共享
# Resolv library for ping6 [yes|static]　＃RESOLV库ping6 [是|静态]
USE_RESOLV=yes　＃默认resolv 库ping6的状态为：是
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]　
ENABLE_PING6_RTHDR=no　＃默认ping6源路由的状态为：没有，这里不推荐使用RFC5095

# rdisc server (-r option) support [no|yes]
ENABLE_RDISC_SERVER=no　＃默认RDISC服务器是不支持－r选项的

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#-Wstrict-prototypes: 如果函数的声明或定义没有指出参数类型，编译器就发出警告
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
CCOPTOPT=-O3　#  对代码进行３级优化
GLIBCFIX=-D_GNU_SOURCE
DEFINES=
LDLIB=

FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2)) #宏定义

＃判断每个函数库中是否重复包含函数
# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
＃判断crypto加密解密函数库中的函数是否重复
ifneq ($(USE_GNUTLS),no)＃ifneq表示条件语句开始
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif＃表示一个条件语句结束

# USE_RESOLV: LIB_RESOLV
＃判断resolv函数库中的函数是否重复
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
＃判断cap函数库中的函数是否重复
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
＃判断sysfs 接口函数库中的函数是否重复
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
＃判断IDN恒等函数库中的函数是否重复
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

＃判断重复加载
# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
＃检查内核模块在编译过程中产生的中间文件即垃圾文件并加以清除
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

all: $(TARGETS)

%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
#
# COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除,  DEF_ping
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)
#
#
#以ping为例，翻译为：
# gcc -O3 -fno-strict-aliasing -Wstrict-prototypes -Wall -g -D_GNU_SOURCE    -c ping.c -DCAPABILITIES   -o ping.o
#gcc   ping.o ping_common.o -lcap    -o ping
# -------------------------------------
# arping
#向相邻主机发送ARP请求
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

ifneq ($(ARPING_DEFAULT_DEVICE),)＃条件语句的开始
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
＃继续追加
＃在$(ARPING_DEFAULT_DEVICE)中存在结尾空格，在这句话中也会被作为makefile需要执行的一部分。
endif

＃linux环境下一些实用的网络工具的工具的集合iputils软件包，以下包含的工具： clockdiff,ping / ping6,rarpd,rdisc,tracepath,tftpd。
# clockdiff
＃测算目的主机和本地主机的系统时间差，clockdiff程序由clockdiff.c文件构成。
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
＃测试计算机名和计算机的ip地址，验证与远程计算机的连接。ping程序由ping.c
ping6.cping_common.c  ping.h文件构成
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
＃逆地址解析协议的服务端程序，rarpd 程序由rarpd.c 文件构成
DEF_rarpd =
LIB_rarpd =

# rdisc
#路由器发现守护程序，rdisc程序由rdisc.c文件构成。
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
#与traceroute功能相似，使用tracepath测试IP数据报文从源主机传到目的主机经过的路由，tracepath程序由tracepath.c tracepath6.c traceroute6.c 文件构成。 
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
#简单文件传送协议TFTP的服务端程序，tftpd程序由tftp.h tftpd.c tftpsubs.c文件构成。
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
ninfod:
	@set -e; \　　　　 #若指令传回值不等于0，则立即退出shell。
		if [ ! -f ninfod/Makefile ]; then \　　#立即跟文件名也可以正常压缩和解压缩
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \　#then 和 fi 在shell里面被认为是分开的语句，fi为if语句的结束,相当于end if
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#将某个程序实体标记为一个建议不再使用的实体。每次使用被标记为已过时的实体时，随后将生成警告或错误，这取决于属性是如何配置的。
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE";#取消echo 的显示  在shell下就显示Please, set correct KERNEL_INCLUDE
 false
else
	@set -e; \　#若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules
#删除已生成的目标文件
# -------------------------------------
man:
	$(MAKE) -C doc man

html:
	$(MAKE) -C doc html

clean:
	@rm -f *.o $(TARGETS) #容错处理
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"　#修补提交（修补最近一次的提交而不创建新的提交）
	@git tag -s -m "iputils-$(TAG)" $(TAG)　#-s如果有自己的私钥，还可以用 GPG 来签署标签
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2　　 仓库中导出项目

