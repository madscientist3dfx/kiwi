# /.../
# Copyright (c) 2006 SUSE LINUX Products GmbH. All rights reserved.
# Author: Marcus Schaefer <sax@suse.de>, 2006
#
# Makefile for OpenSuSE - KIWI Image System
# ---
buildroot = /
syslinux  = /usr/share/syslinux
bindlib   = lib

export

#============================================
# Prefixs...
#--------------------------------------------
bin_prefix  = ${buildroot}/usr/bin
init_prefix = ${buildroot}/etc/init.d
kiwi_prefix = ${buildroot}/usr/share/kiwi
tftp_prefix = ${buildroot}/srv/tftpboot
doc_prefix  = ${buildroot}/usr/share/doc/packages
man_prefix  = ${buildroot}/usr/share/man

#============================================
# Variables... 
#--------------------------------------------
KIWIBINVZ   = ${buildroot}/usr/sbin
KIWIMODVZ   = ${kiwi_prefix}/modules
TOOLSVZ     = ${bin_prefix}
INITVZ      = ${init_prefix}
KIWIIMAGE   = ${kiwi_prefix}/image
TFTPKIWI    = ${tftp_prefix}/KIWI
TFTPBOOT    = ${tftp_prefix}/
TFTPBOOTBOOT= ${tftp_prefix}/boot
TFTPBOOTCONF= ${tftp_prefix}/pxelinux.cfg
TFTPUPLOAD  = ${tftp_prefix}/upload
TFTPIMAGE   = ${tftp_prefix}/image
PACKDOCVZ   = ${doc_prefix}/kiwi
MANVZ       = ${man_prefix}/man1

all: modules/KIWIScheme.rng
	#============================================
	# create checksum files for boot images...
	#--------------------------------------------
	(cd system/boot && ./.md5)
	(cd system/boot && find -type f | grep -v .svn | xargs chmod u-w)

	#============================================
	# build tools
	#--------------------------------------------
	${MAKE} -C tools all

install:
	#============================================
	# Install base directories
	#--------------------------------------------
	install -d -m 755 ${KIWIBINVZ} ${KIWIMODVZ} ${KIWIIMAGE}
	install -d -m 755 ${TFTPKIWI} ${TFTPBOOT} ${TFTPBOOTCONF} ${TFTPIMAGE}
	install -d -m 755 ${TFTPBOOTBOOT}
	install -d -m 755 ${TFTPUPLOAD}
	install -d -m 755 ${PACKDOCVZ} ${MANVZ}
	install -d -m 755 ${TOOLSVZ} ${INITVZ}

	#============================================
	# install .revision file
	#--------------------------------------------
	test -f ./.revision || ./.version > .revision
	install -m 644 ./.revision ${kiwi_prefix}

	#============================================
	# kiwi system draft and examples
	#--------------------------------------------
	cp -a doc/* ${PACKDOCVZ}

	#============================================
	# kiwi manual pages
	#--------------------------------------------
	for i in `ls -1 ./doc/kiwi-man`;do \
		install -m 644 ./doc/kiwi-man/$$i ${MANVZ} ;\
	done

	#============================================
	# Install kiwi tools
	#--------------------------------------------
	${MAKE} -C tools TOOLSVZ=${TOOLSVZ} INITVZ=${INITVZ} install

	#============================================
	# Install KIWI base and modules
	#--------------------------------------------
	install -m 755 ./kiwi.pl       ${KIWIBINVZ}/kiwi
	install -m 644 ./modules/*     ${KIWIMODVZ}

	#============================================
	# Install TFTP netboot structure and loader
	#--------------------------------------------
	install -m 755 ${syslinux}/pxelinux.0     ${TFTPBOOT}/pxelinux.0
	test -f ${syslinux}/mboot.c32 && \
		install -m 755 ${syslinux}/mboot.c32  ${TFTPBOOT}/mboot.c32 || /bin/true
	install -m 644 pxeboot/README             ${TFTPBOOT}
	install -m 644 pxeboot/README.prebuild    ${TFTPBOOT}
	#install -m 755 pxeboot/pxelinux.0.config ${TFTPBOOTCONF}/default

	#============================================
	# Install image descriptions
	#--------------------------------------------
	cp -a system/boot/* ${KIWIIMAGE}

modules/KIWIScheme.rng: modules/KIWIScheme.rnc
	#============================================
	# Convert RNC -> RNG...
	#--------------------------------------------
	@echo "*** Converting KIWI RNC -> RNG..."
	trang -I rnc -O rng modules/KIWIScheme.rnc modules/KIWIScheme.rng

	#============================================
	# Check RNG Scheme...
	#--------------------------------------------
	for i in `find -name config.xml`;do \
		echo $$i; j=`jing modules/KIWIScheme.rng $$i`;if test ! -z "$$j";then\
			echo $$j; break;\
		fi;\
	done; test -z "$$j" || false

clean:
	rm -f modules/KIWIScheme.rng
	${MAKE} -C tools clean
