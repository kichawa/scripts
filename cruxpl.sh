#!/bin/bash
# cruxpl is a simple script for git reposiotry mirroring, written to be used with cron.
#
#    Copyright (C) 2009, 2010 Marcin Karpezo
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

LOG="$HOME/www/mainsite/static/download/cruxpl-ports/cruxpl.log"

cd ~/www/mainsite/static/download/cruxpl-ports

if [ ! -e "$LOG" ]; then
touch $LOG
fi

echo -e "Checking: `date`">> "$LOG" && git pull origin master >> "$LOG"

if [ "$?" -ne "0" ]; then
    echo -e "Error: `date`\n" >> "$LOG"
fi
