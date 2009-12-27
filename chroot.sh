#!/bin/bash
# Simple script to make and enter chroot environment, this script should be executed with root privileges.
#
#    Copyright (C) 2009 Marcin Karpezo <sirmacik at gmail dot com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Settings 
CHPATH="/media/crux" # chroot mountpoint
ROOTPART="/dev/sda1" # chroot root partition 


check(){
    if [ "$?" == "0" ]; then
        echo -e "    [OK!]\n"
    else
        echo -e "    [ERROR] Can't mount or already mounted!\n"
    fi
}

echo -e "Copyright (C) 2009  Marcin Karpezo\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions; Read COPYING file for details.\n"

read -p "Mount partitions and prepare internet connection? [Y/n] " answer
if [ "$answer" = "n" ]; then 
    echo "No!"
else
    echo "Yes!"
    echo "Mounting..."
    read -p "Mount root? [Y/n] " mntroot
    if [ "$mntroot" = "n" ]; then
        echo "        No!"
    else
        echo -e "      /..."
        mount $ROOTPART $CHPATH
        check
    fi
    echo -e "      /proc..."
    mount -t proc none $CHPATH/proc
    check
    echo -e "      /dev..."
    mount -o bind /dev $CHPATH/dev 
    check
    echo -e "      /tmp..."
    mount --bind /tmp $CHPATH/tmp 
    check
    echo -e "      /sys..."
    mount -t sysfs none $CHPATH/sys
    check
    echo -e "      /home..."
    mount --bind /home $CHPATH/home
    check 
    
    echo "Copying resolv.conf..."
    cp -L /etc/resolv.conf $CHPATH/etc/
fi

echo "Entering chroot environment..."
chroot $CHPATH /bin/bash

read -p "Unmount partitions? [Y/n] " mount_answer
if [ "$mount_answer" = "n" ]; then
    echo "No!"
    exit 0
else
    echo "Unmounting..."
    echo -e "      /proc..."
    umount $CHPATH/proc
    check
    echo -e "      /dev..."
    umount $CHPATH/dev
    check
    echo -e "      /tmp..."
    umount $CHPATH/tmp
    check
    echo -e "      /sys..."
    umount $CHPATH/sys
    check
    echo -e "      /home..."
    umount $CHPATH/home
    check
    read -p "Unmount root? [Y/n] " root_answer
    if [ "$root_answer" = "n" ]; then
        echo "No!"
    else
        echo -e "      /..."
        umount "$CHPATH"
        check
    fi
fi


