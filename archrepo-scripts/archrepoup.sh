#/bin/bash
# Copyright (c) 2009, Marcin Karpezo 
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

DEST="archrepo@archrepo.net:/usr/home/archrepo/" #change this path with Your shell and directory
USR="$1" 
PKGDIR="$2"

helpmsg(){
    echo "Simple script for copying and synchronising Your packages to ArchRepo!"
    echo "      Usage: $0 [option/user] [pkgdir]"
    echo "Available options:"
    echo "      help - displays this message"    
    echo "      sync - synchronize package database"
    echo "WARNING: To run this script successfully Your rsa.pub key has to be added on repository server."
    exit 0
}

is_file (){
    # --{{{ Check for packages in pkgdir
    for f in "$PKGDIR"/*pkg.tar.gz; do
        [ -f "$f" ] && return;
    done;
    # --}}}
}

check(){
    # --{{{ Check if there was an error
    if [ "$?" == "0" ]; then
        echo "[OK!]"
    else
        echo "[ERROR!]"
        exit 1
    fi
    # --}}}
}

lock(){
    # --{{{ Lock for uploading
    echo -e "Locking... \c "
    touch lock 
    scp -q lock $DEST/$USR/  
    check
    # --}}}
}

unlock(){
    # --{{{ Unlock after upload or error
    echo -e "Unlocking... \c "
    ssh archrepo@archrepo.net -q "rm /usr/home/archrepo/$USR/lock"
    check
    rm lock
    # --}}}
}

copy(){
    # --{{{ Copy packages to server 
    echo "Copying packages..."
    echo "Package(s) to upload:"
    if [ -z "$PKGDIR" ]; then
        echo "[ERROR!] Set package directory! More info under: $0 help"
        unlock
        exit 1
    elif [ -f "$PKGDIR" ]; then
        echo $PKGDIR
        read -p "Proceed? [Y/n] " copy_answer
        if [ "$copy_answer" = "n" ]; then
            echo "Stop!"
            exit 1
        else
            echo "Copying..."
            echo -e "$PKGDIR \c "
            chmod 644 $PKGDIR
            scp -qp $PKGDIR $DEST/$USR/
            check
        fi
    elif [ -d "$PKGDIR" ] && is_file; then
        for f in "$PKGDIR"/*pkg.tar.gz; do
           echo "$f" 
        done;
        read -p "Proceed? [Y/n] " copy_answer
        if [ "$copy_answer" = "n" ]; then
            echo "Stop!"
            exit 1
        else
            echo "Copying..."
            chmod 644 $PKGDIR/*pkg.tar.gz 
            for f in "$PKGDIR"/*pkg.tar.gz; do
                echo -e "$f \c "
                scp -qp "$f" $DEST/$USR/
                check
            done;
        fi
    else
        echo "[ERROR!] Add some packages to pkgdir!"
        unlock
        exit 1
    fi
    # --}}}
}
syncpkgs(){
    # --{{{ Run serverside script
    echo "Synchronizing packages database..."
    ssh archrepo@archrepo.net "archrepo_manage.py"
    check
    # --}}}
}

question(){
    # --{{{ Removing uploaded packages
    read -p "Do You want me to remove local packages? [y/N] " answer
    if [ "$answer" = "y" ]; then
        if [ -f "$PKGDIR" ]; then
            rm $PKGDIR
        else
            rm $PKGDIR/*pkg.tar.gz
        fi
    else
        exit 0
    fi
    # --}}}}
}
if [ "$1" = "help"  ] || [ -z "$1" ]; then
    helpmsg
elif [ "$1" = "sync" ]; then
    syncpkgs
elif [ "$USR" = "dziq" ] || [ "$USR" = "virhilo" ] || [ "$USR" = "sirmacik" ]; then
    lock
    copy
    unlock
    syncpkgs
    question    
else 
    helpmsg
fi

