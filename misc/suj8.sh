#!/bin/sh

#
# Copyright (c) 2011 Peter Holm <pho@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD: projects/stress2/misc/suj.sh 210724 2010-08-01 10:33:03Z pho $
#

[ `id -u ` -ne 0 ] && echo "Must be root!" && exit 1

# fsck modifies the fs_time without reason for SU+J, when "disk full" or
# "out of inodes" has been reached.

. ../default.cfg

mount | grep $mntpoint | grep -q /dev/md && umount -f $mntpoint
mdconfig -l | grep -q md$mdstart &&  mdconfig -d -u $mdstart

mdconfig -a -t swap  -s 128M -u $mdstart || exit 1
bsdlabel -w md$mdstart auto

n=0
for i in 1 2 ; do
	n=$((n + 1))
	echo "newfs -U md${mdstart}$part"
	newfs -U md${mdstart}$part > /dev/null
	[ $n -eq 2 ] && tunefs -j enable /dev/md${mdstart}$part

	mount /dev/md${mdstart}$part $mntpoint

	dd if=/dev/zero of=/mnt/big bs=4k > /dev/null 2>&1

	while mount | grep $mntpoint | grep -q /dev/md; do
		umount $mntpoint || sleep 1
	done
	dumpfs /dev/md${mdstart}$part > /tmp/dumpfs.1
	sleep 1
	fsck -t ufs -y /dev/md${mdstart}$part > /tmp/fsck.log 2>&1
	dumpfs /dev/md${mdstart}$part > /tmp/dumpfs.2

	diff -c /tmp/dumpfs.1 /tmp/dumpfs.2 || cat /tmp/fsck.log
done

mdconfig -d -u $mdstart
rm -f /tmp/fsck.log /tmp/dumpfs.?
