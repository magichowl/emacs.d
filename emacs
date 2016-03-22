#!/bin/sh
# ~/bin/emacs


#
# "apt-get install gnuserv"
# "apt-get install lsof" - if you're missing "lsof".
#
emacs_process_id=$(pidof emacs24)
if [ -z $emacs_process_id ]; then
    /usr/bin/emacs24 "$*" &
else
    /usr/bin/gnuclient "$*" &
fi

