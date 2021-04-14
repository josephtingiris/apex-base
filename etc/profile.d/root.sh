if [ "$USER" == "root" ] && [ "$SSH_TTY" != "" ]; then
    if [ ! -f ~/.Allow ]; then
        echo
        echo "Don't log in as root; Log in as a user and use sudo."
        echo
        exit
    fi
fi
