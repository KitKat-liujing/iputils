#
# Configuration　配置
#

# CC　指定gcc程序
CC=gcc
# Path to parent kernel include files directory　路径的父内核头文件目录
LIBC_INCLUDE=/usr/include　#指定库函数的路径
# Libraries　#添加其他的库（包括静态的和动态的）
ADDLIB=　　　#不添加其他的库
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
LDFLAG_CRYPTO=-lcrypto＃加载rypto加密解密函数库
LDFLAG_IDN=-lidn  #加载idn恒等函数库
LDFLAG_RESOLV=-lresolv＃加载resolv函数库
LDFLAG_SYSFS=-lsysfs　＃加载sysfs接口函数库

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

# Do not use getifaddrs [no|yes|static]
WITHOUT_IFADDRS=no ＃默认不使用getifaddrs函数获得接口的相关信息
# arping default device (e.g. eth0) []　
＃arping默认设备，如网卡、以太网、无线
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]　
USE_GNUTLS=yes　#允许ping6加密协议库
# Crypto library for ping6 [shared|static]　
USE_CRYPTO=shared　#允许和ping6共享加密的库
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
#表示编写的代码符合GUN规范
#于Linux下的信号量/读写锁文件进行编译，需要在编译选项中指明-D_GNU_SOURCE 
DEFINES=
LDLIB=

#选择库函数
#如果过滤掉参数1中除了静态函数外的其他函数，就将$(1)),$(LDFLAG_STATIC) $(2)这几个变量所代表的库赋给FUNC_LIB
#否则，只将参数2赋给FUNC_LIB
FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

＃判断每个函数库中是否重复包含函数
# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
＃判断crypto加密解密函数库中的函数是否重复
ifneq ($(USE_GNUTLS),no)＃ifneq表示条件语句开始,如果USE_GNUTLS不是"no",如果USE_GNUTLS不是"no",则以变量USE_GNUTLS和LDFLAG_GNUTLS的内容为参数调用FUNC_LIB,并将结果赋给LIB_CRYPTO。
#因为USE_GNUTLS的值是yes,所以可以调用。
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS  #将-DUSE_GNUTLS这个参数赋给DEF_CRYPTO.
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))    #将-DUSE_GNUTLS这个参数赋给DEF_CRYPTO.
endif＃表示一个条件语句结束

# USE_RESOLV: LIB_RESOLV
＃判断resolv函数库中的函数是否重复
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV)) #以变量USE_RESOLV和LDFLAG_RESOLV的内容为参数调用FUNC_LIB,并将结果赋给LIB_RESOLV。

# USE_CAP:  DEF_CAP, LIB_CAP
＃判断cap函数库中的函数是否重复
ifneq ($(USE_CAP),no)   #判断USE_CAP的值是否为no。
	DEF_CAP = -DCAPABILITIES  #如果不是则将参数-DCAPABILITIES赋给DEF_CAP
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))   #以变量USE_CAP和LDFLAG_CAP的内容为参数调用FUNC_LIB,并将结果赋给 
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
ifneq ($(USE_SYSFS),no)  #判断USE_SYSFS是否为no
	DEF_SYSFS = -DUSE_SYSFS    #如果不是则将参数-DUSE_SYSFS 赋给 DEF_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS)) #以变量USE_SYSTEM和LDFLAG_CAP的内容为参数调用LDFLAG_SYSFS,并将结果赋给LIB_SYSFS。
endif

# USE_IDN: DEF_IDN, LIB_IDN
ifneq ($(USE_IDN),no) #判断USE_IDN是否为no
	DEF_IDN = -DUSE_IDN  #将-DUSE_IDN赋给变量DEF_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN)) #以变量USE_IDN和LDFLAG_CAP的内容为参数调用FUNC_LIB,并将结果赋给LIB_IDN。	
endif

＃判断重复加载
# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
ifneq ($(WITHOUT_IFADDRS),no)  #判断WITHOUT_IFADDRS的值是否为no
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS  #如果不是—DWITHOUT_IFADDRS赋给变量DEF_WITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
ifneq ($(ENABLE_RDISC_SERVER),no) 
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER #如果不是，则将参数-DRDISC_SERVER赋给变量DEF_ENABLE_RDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
ifneq ($(ENABLE_PING6_RTHDR),no)#判断ENABLE_PING6_RTHDR的值是否为no
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR #如果不是，则将-DPING6_ENABLE_RTHDR赋给变量
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)#判断ENABLE_PING6_RTHDR是否等于RFC3542
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542　#如果是，则将 -DPINR6_ENABLE_RTHDR_RFC3542追加给变量
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)＃ 编译选项
LDLIBS=$(LDLIB) $(ADDLIB)　 #链接的库函数

#将命令 uname -n 的输出给变量UNAME_N
UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')#将HEAD中的-.*替换为/
TODAY=$(shell date +%Y/%m/%d)#用%Y/%m/%d的格式输出年月日， 并保存到TODAY变量中。
DATE=$(shell date --date $(TODAY) +%Y%m%d)#将TODAY中的内容以%Y%m%d的格式赋给DATE
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)#将TODAY的内容以s%Y%m%d的格式赋给TAG


# -------------------------------------
＃检查内核模块在编译过程中产生的中间文件即垃圾文件并加以清除
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot
#.PHONY后面是伪目标文件，通过make+不同的命令来执行。
all: $(TARGETS)

%.s: %.c　＃符号％是通配符，%.s依赖%.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@ #删除所有的.o文件，将所有的.c文件编译成对应的.s文件。
%.o: %.c  ＃%.o依赖%.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@#将所有的.o文件编译生成目标所要的可执行文件。
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

tftpd: tftpsubs.o　#tftpd依赖tftpsus.o文件
tftpd.o tftpsubs.o: tftp.h　#tftpd.o和tftpsubs.o文件依赖tftp.h头文件

# -------------------------------------
# ninfod
＃生成ninfod可执行文件
ninfod:
	@set -e; \　　　　 #如果ninfod目录下没有Makefile文件，就创建一个
		if [ ! -f ninfod/Makefile ]; then \　　
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \　#then 和 fi 在shell里面被认为是分开的语句，fi为if语句的结束,相当于end if
		$(MAKE) -C ninfod　＃否则，直接指定ninfod为读取Makefile的一个路径。

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#将某个程序实体标记为一个建议不再使用的实体。每次使用被标记为已过时的实体时，随后将生成警告或错误，这取决于属性是如何配置的。
check-kernel:　＃检查内核
ifeq ($(KERNEL_INCLUDE),)　#如果变量KERNEL_INCLUDE是空，则报错。
	@echo "Please, set correct KERNEL_INCLUDE";#取消echo 的显示  在shell下就显示Please, set correct KERNEL_INCLUDE
 false
else
	@set -e; \　#若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \　#如果autoconf.h不是一个普通文件，则报错。
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules
　　　#指定Modules路径中的Makefile文件编译内核
# -------------------------------------
man:
	$(MAKE) -C doc man　#生成man的帮助文档

html:
	$(MAKE) -C doc html　#生成网页格式的帮助文档

clean:
	@rm -f *.o $(TARGETS)  #删除所有生成的目标的二进制文件
　　#指定读取makefile的目录。
	@$(MAKE) -C Modules clean　#执行Modules目录下Makefile中的clean，删除指定的文件。
	@$(MAKE) -C doc clean　#执行doc目录下Makefile中的clean，删除指定的文件。
	@set -e; \
		if [ -f ninfod/Makefile ]; then \　#如果ninfod目录下存在makefile文件，就进入ninfod目录并读取malefile文件，
#执行clean操作， 清除之前编译的可执行文件及配置文件。

			$(MAKE) -C ninfod clean; \
		fi

distclean: clean　#清除ninfod目录下所有生成的文件。
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi　#如果UNAME_N和pleiades的十六进制不等，提示信息，并退出。
	@echo "[$(TAG)]" > RELNOTES.NEW　#将TAG变量的内容重定向到RELNOTES.NEW文档中。
	@echo >>RELNOTES.NEW　#输出一个空行
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
#将RELNOTES里的内容重定向的RELNOTES.NEW文档里。
	@echo >> RELNOTES.NEW　#输出一个空行
	@cat RELNOTES >> RELNOTES.NEW	#将RELNOTES里的内容重定向的RELNOTES.NEW文档里。
	@mv RELNOTES.NEW RELNOTES#将RELNOTES.NEW文档重命名为RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"　#修补提交（修补最近一次的提交而不创建新的提交）
	@git tag -s -m "iputils-$(TAG)" $(TAG)　#-s如果有自己的私钥，还可以用 GPG 来签署标签
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2　　 仓库中导出项目

