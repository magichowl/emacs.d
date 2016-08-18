#!/usr/bin/python
import re, os

def get_password_emacs(machine, login, port):
    s = "machine %s login %s port %s password ([^ ]*)\n" % (machine, login, port)
    p = re.compile(s)
    authinfo = os.popen("gpg2 -q --no-tty -d ~/.authinfo.gpg").read()
    match = p.search(authinfo)
    if match:
        return match.group(1)
    else:
        print 'no match!'
    # return p.search(authinfo).group(1)

# get_password_emacs("imap.163.com", "magichowl@163.com", "993")