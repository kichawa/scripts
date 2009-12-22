#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 0.6
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import os
from subprocess import Popen

if (len(sys.argv) > 1):
    name = sys.argv[1]
else:
    name = ''

def mime(s):
    file = Popen('file'+' -Ls '+s, shell=True)
    os.waitpid(file.pid, 0)
    
def extract(s):
    if s.endswith('.tar.bz2') or s.endswith('.tbz2'):
        archive = 'tar'+' -xjf'
    elif s.endswith('.tar.gz') or s.endswith('.tgz'):
        archive = 'tar'+' -xzf'
    elif s.endswith('.bz2'):
        archive = 'bunzip2'
    elif s.endswith('.gz'):
        archive = 'gunzip'
    elif s.endswith('.tar'):
        archive = 'tar'+' -xf'
    elif s.endswith('.zip') or s.endswith('.ZIP'):
        archive = 'unzip'
    elif s.endswith('.rar') or s.endswith('.RAR'):
        archive = 'unrar'+' x'
    elif s.endswith('.Z'):
        archive = 'uncompress'
    elif s.endswith('.tar.lzma'):
        archive = 'tar'+' -x'+' --lzma'
    elif s.endswith('.lzma'):
        archive = 'lzma'+' -d'
    elif s.endswith('.tar.7z'):
        archive = 'tar'+' -x --use-compress-program=7za'
    elif s.endswith('.7z'):
        archive = '7za'+' x'
    else: 
        archive = ''
    
    if (len(archive) > 1):    
        command = Popen(archive+' '+s, shell=True)
        os.waitpid(command.pid, 0)
    else: 
        sys.stderr.write('Error: Unknown or invalid type of archive\n')
        mime(s)
try:
    if (name.find('--help') != -1):
        print "To extract Your archive You have to add name of file as an argument. \nExample: \n    extractor archive.tar.gz \nTo check mime type of Your archive run extractor with option '--mime-type'. \nExample: \n    extractor --mime-type archive.tar.gz"
    elif (name.find('--mime-type') != -1):
	filetest = sys.argv[2]
	mime(filetest)
    elif (len(name) > 1):
        extract(name)
    else:
        sys.stderr.write('Error: Add name of archive! \nExample: \n    extractor archive.tar.gz\n')
    
except IndexError: 
    sys.stderr.write('Error: Wrong filename\n')
