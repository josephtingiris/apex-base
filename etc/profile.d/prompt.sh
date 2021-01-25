if [ "$TERM" == "xterm" ] || [ "$TERM" == "ansi" ] || [[ "$TERM" == *color ]]; then
    if [ "$USER" == "root" ]; then
        #export PS1="\[$(tput setaf 1)\][\u@\h \w]# \[$(tput sgr0)\]" # red
        export PS1="\[$(tput setaf 3)\][\u@\h \w]# \[$(tput sgr0)\]" # yellow(ish)
        #export PS1="\[$(tput setaf 4)\][\u@\h \w]# \[$(tput sgr0)\]" # dark blue
        #export PS1="\[$(tput setaf 5)\][\u@\h \w]# \[$(tput sgr0)\]" # purple
        #export PS1="\[$(tput setaf 7)\][\u@\h \w]# \[$(tput sgr0)\]" # white
    else
        #export PS1="\[$(tput setaf 6)\][\u@\h \w]$ \[$(tput sgr0)\]" # cyan
        export PS1="\[$(tput setaf 2)\][\u@\h \w]$ \[$(tput sgr0)\]" # green
    fi
fi
