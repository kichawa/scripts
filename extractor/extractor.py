#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = BSD 
#   All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, 
#       this list of conditions and the following disclaimer in the documentation 
#       and/or other materials provided with the distribution.
#     * Neither the name of the ArchRepo nor the names of its contributors may 
#       be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.

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
