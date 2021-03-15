#!/bin/bash

# This is a base include file; common globals & functions
#
# 20150607, joseph.tingiris@gmail.com
# 20150621, joseph.tingiris@gmail.com, revised (new naming convention & organization)

# For coding conventions, organization, standards, & references, see: /base/README

# bash mandatory; disable all globbing
set -f

if [ "$BASE_DIR" == "" ]; then
    BASE_DIRS="/base /mux"
    for BASE_DIR in $BASE_DIRS; do
        if [ -d "$BASE_DIR" ]; then break; fi
    done
    if [ "$BASE_DIR" == "" ]; then BASE_DIR="/base"; fi
fi

PATH="$BASE_DIR/bin:$BASE_DIR/sbin:/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin${PATH:+:${PATH}}"

# mandatory dependency check

function Dependency() {

    # begin function logic

    local dependencies="$1"

    for dependency in $dependencies; do
        which $dependency &> /dev/null
        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo "can't find dependency '$dependency'"
            exit 2
        fi
    done

    dependency=""

    # end function logic
}
Dependency "which
awk
basename
cut
date
dirname
egrep
find
grep
head
host
hostname
ip
printf
pwd
readlink
sed
sort
stat
svn
tail
tput
uniq
uuidgen
who"

# GLOBAL_VARIABLES

# be careful changing the order of these

BASE_INCLUDE="$BASH_SOURCE"

if [ "$DEBUG" == "" ]; then DEBUG=0; fi

if [ "$DEBUG_FLAG" == "" ]; then declare -i DEBUG_FLAG=0; fi

if [ "$UNIQ" == "" ]; then UNIQ=$(date +%Y%m%d)-$(uuidgen); fi

if [ "$USER" == "" ]; then USER="nobody"; fi

ARGUMENTS=$@

declare -i ARGUMENTS_TOTAL=$#

if [ "$BASE_0" == "" ]; then BASE_0=$0; fi
if [ "$BASE_0" == "-bash" ]; then BASE_0="base.bash"; fi

if [ -r "$BASE_DIR/bin/base-host" ]; then
    source "$BASE_DIR/bin/base-host"
    baseHost $HOSTNAME
fi

if [ "$BASE_DIR_ACCOUNT" == "" ]; then
    BASE_DIR_ACCOUNT="$BASE_DIR/account"
fi

if [ "$BASE_ACCOUNT" == "" ]; then
    BASE_ACCOUNT=$(pwd | awk -F\/ '{print $4}')
    if [ ! -d "$BASE_DIR_ACCOUNT/$BASE_ACCOUNT" ]; then
        BASE_ACCOUNT=""
    fi
fi

[ -z "$BASE_ACCOUNT" ] && BASE_ACCOUNT="$BASE_HOST_ACCOUNT"

if [ "$BASE_ARG" == "" ]; then BASE_ARG=$ARGUMENTS; fi

if [ "$BASE_BACKUP" == "" ]; then BASE_BACKUP=/backup; fi

BASE_DIR_0=$(dirname $BASE_0)

if [ "$BASE_COMPANY" == "" ]; then
    if [ -r "/etc/company_name" ]; then
        BASE_COMPANY=$(cat "/etc/company_name")
    else
        if [ -r "$BASE_DIR/etc/company_name" ]; then
            BASE_COMPANY=$(cat "$BASE_DIR/etc/company_name")
        else
            BASE_COMPANY="No Company Name"
        fi
    fi
fi

if [ "$BASE_DATACENTERS" == "" ]; then BASE_DATACENTERS="atl dal lon man"; fi

if [ "$BASE_DOMAIN" == "" ]; then
    if [ -r "/etc/domain_name" ]; then
        BASE_DOMAIN=$(cat "/etc/domain_name")
    else
        if [ -r "$BASE_DIR/etc/domain_name" ]; then
            BASE_DOMAIN=$(cat "$BASE_DIR/etc/domain_name")
        else
            BASE_DOMAIN=localdomain
        fi
    fi
fi

if [ "$BASE_ENVIRONMENTS" == "" ]; then BASE_ENVIRONMENTS="dev qa rep stg test prod"; fi

if [ "$BASE_NAME" == "" ]; then BASE_NAME="$(basename $BASE_0)"; fi

if [ "$BASE_PID" == "" ]; then BASE_PID=$BASHPID; fi

if [ "$BASE_TOP" == "" ]; then BASE_TOP="$BASE_DIR"; fi

if [ "$HERE" == "" ]; then HERE=$(readlink -f $(pwd)); fi

if [ "$HOSTNAME" == "" ]; then HOSTNAME=$(hostname -s); fi

if [ "$LOGFILE" == "" ]; then LOGFILE="/tmp/${BASE_NAME}.log"; fi

if [ "$LOCKFILE" == "" ]; then LOCKFILE="/tmp/${BASE_NAME}.lock"; fi

if [ "$LOCKFILE_FLAG" == "" ]; then LOCKFILE_FLAG=0; fi

if [ "$LOGNAME" == "" ]; then LOGNAME="$USER"; fi

if [ "$LOGNAME" == "" ]; then LOGNAME="nobody"; fi

[ -n "$BASE_HOST_SERVICE" ] && MACHINE_CLASS="$BASE_HOST_SERVICE"
if [ "$MACHINE_CLASS" == "" ]; then MACHINE_CLASS=$(echo $HOSTNAME | awk -F\. '{print $1}' | sed -e '/[0-9]/s///g'); fi

[ -n "$BASE_HOST_ENVIRONMENT" ] && MACHINE_ENVIRONMENT="$BASE_HOST_ENVIRONMENT"
if [ "$MACHINE_ENVIRONMENT" == "" ]; then declare -l MACHINE_ENVIRONMENT=$(echo $HOSTNAME | awk -F\. '{print $1}' | awk -F- '{print $2}'); fi
if [ "$MACHINE_ENVIRONMENT" == "" ] && [ "${MACHINE_ENVIRONMENT:0:3}" == "dev" ]; then MACHINE_ENVIRONMENT="dev"; fi
if [ "$MACHINE_ENVIRONMENT" == "" ] && [ "${MACHINE_ENVIRONMENT:0:5}" == "local" ]; then MACHINE_ENVIRONMENT="local"; fi
if [ "$MACHINE_ENVIRONMENT" == "" ] && [ "${MACHINE_ENVIRONMENT:0:2}" == "qa" ]; then MACHINE_ENVIRONMENT="qa"; fi
if [ "$MACHINE_ENVIRONMENT" == "" ] && [ "${MACHINE_ENVIRONMENT:0:3}" == "stg" ]; then MACHINE_ENVIRONMENT="stg"; fi
if [ "$MACHINE_ENVIRONMENT" == "" ]; then MACHINE_ENVIRONMENT="prod"; fi

[ -n "$BASE_HOST_NAME" ] && MACHINE_NAME="$BASE_HOST_NAME"
if [ "$MACHINE_NAME" == "" ]; then MACHINE_NAME=$HOSTNAME; fi

if [ "$MACHINE_DIR" == "" ]; then MACHINE_DIR="$BASE_DIR/machine"; fi

if [ "$OPTION" == "" ]; then declare -i OPTION=0; fi

if [ "$OPTIONS" == "" ]; then OPTIONS="debug*[=level] print debug messages (less than) [level]*true:help*print this message*true:version*print version*true"; fi

if [ "$PWD" == "" ]; then PWD=$(pwd); fi

if [ "$QUESTION_FLAG" == "" ]; then declare -i QUESTION_FLAG=0; fi

if [ "$SSH" == "" ]; then SSH=$(which ssh | grep -v ^which:); fi

if [ "$STEP" == "" ]; then declare -i STEP=0; fi

if [ "$SVN" == "" ]; then SVN=$(which svn | grep -v ^which:); fi

if [ "$SVN_DIR" == "" ]; then SVN_DIR="/var/svn"; fi

if [ "$SVN_BRANCH" == "" ]; then SVN_BRANCH="svn+ssh://svn.$BASE_DOMAIN/repo$BASE_DIR/branch"; fi

if [ "$SVN_SERVER" == "" ]; then SVN_SERVE=$(which svnserve); fi

if [ "$SVN_TAG" == "" ]; then SVN_TAG="svn+ssh://svn.$BASE_DOMAIN/repo$BASE_DIR/tag"; fi

if [ "$SVN_TOP" == "" ]; then SVN_TOP=$SVN_DIR; fi

if [ "$SVN_TRUNK" == "" ]; then SVN_TRUNK="svn+ssh://svn.$BASE_DOMAIN/repo$BASE_DIR/trunk"; fi

if [ "$TIME_START" == "" ]; then TIME_START=$(date +%s%N); fi

if [ "$TERM" == "" ]; then TERM="vt100"; fi

if [ "$TMPFILE" == "" ]; then TMPFILE="/tmp/$(basename $BASE_0).${UNIQ}.tmp"; fi

if [ "$VERBOSE_FLAG" == "" ]; then declare -i VERBOSE_FLAG=0; fi

if [ "$VERSION" == "" ]; then VERSION="0"; fi

if [ "$WHOM" == "" ]; then WHOM=$(who -m); fi

if [ "$WHO" == "" ]; then WHO="${WHOM%% *}"; fi

if [ "$WHO" == "" ]; then WHO=$USER; fi

if [ "$WHO" == "" ]; then WHO=$LOGNAME; fi

if [ "$WHO" == "" ]; then WHO=UNKNOWN; fi

if [ "$WHO_IP" == "" ]; then WHO_IP="${WHOM#*(}"; WHO_IP="${WHO_IP%)*}"; fi

if [ "$WHO_IP" == "" ] && [ "$SSH_CLIENT" != "" ]; then WHO_IP=${SSH_CLIENT%% *}; fi

if [ "$WHO_IP" == "" ]; then WHO_IP="0.0.0.0"; fi

if [ "$YES_FLAG" == "" ]; then declare -i YES_FLAG=0; fi

# much of this script depends on BASE_DIR, so make sure it's there & valid
if [ ! -d "$BASE_DIR" ]; then

    # svn is mandatory (or is it??), don't proceed without it (rethink this some day)
    if [ "$SVN" == "" ]; then
        echo
        echo "aborting, can't find svn ..."
        echo
        Stop 9
    fi

    echo
    echo -n "$BASE_DIR not found; Do you want to check it out from svn.$BASE_DOMAIN ? "
    read BASE_DIR_CHECK_OUT
    if [ "$BASE_DIR_CHECK_OUT" == "y" ]; then

        # crude, but I'm embedding a requirement for an svnserve wrapper intentionlally (because of umask, dav, etc); -jjt
        if [ ! -x $SVN_SERVE ]; then
            echo "#!/bin/bash" > $SVN_SERVE
            echo >> $SVN_SERVE
            echo "PATH=/bin:/usr/bin:/sbin:/usr/sbin" >> $SVN_SERVE
            echo >> $SVN_SERVE
            echo "# set the umask so files are group-writable" >> $SVN_SERVE
            echo "umask 002" >> $SVN_SERVE
            echo >> $SVN_SERVE
            echo "# call the 'real' svnserve, also passing in the default repo location" >> $SVN_SERVE
            echo "exec /usr/bin/svnserve \"\$@\" -r $SVN_DIR" >> $SVN_SERVE
            chmod 755 $SVN_SERVE
        fi

        echo "using $SVN  to check out $SVN_TRUNK ..."
        $SVN co $SVN_TRUNK $BASE_DIR
        RETURN_CODE=$?
        if [ $RETURN_CODE -ne 0 ]; then
            Aborting "'$SVN co $SVN_TRUNK $BASE_DIR' failed" 2
        fi
        RETURN_CODE=""
    else
        echo
        echo "aborting, can't proceed without base top directory $BASE_DIR ..."
        echo
        Stop 9
    fi

    # end check for BASE_DIR
fi

# Functions

function _Prototype_Function() {
    Debug_Function $@ # call Debug_Function when the function finished

    # begin function logic

    echo "Hello World!"

    # end function logic

    Debug_Function $@ # call Debug_Function again to know when the function finished
}

function Aborting() {
    Debug_Function $@

    # begin function logic

    if [ "$2" == "" ]; then
        local -i return_code="$2"
    else
        local -i return_code=9
    fi
    local aborting_message="aborting, $1 ($return_code) ..."

    echo
    echo "$aborting_message"
    echo

    System_Log "$aborting_message"

    Stop $return_code

    # end function logic

    Debug_Function $@
}

function Backup_Files() {
    Debug_Function $@

    # begin function logic

    if [ "$1" == "" ]; then
        return
    else
        local backup_files="$1"
    fi

    if [ "$2" == "" ]; then
        local backup_files_directory=$BASE_BACKUP
    else
        local backup_files_directory="$2"
    fi

    if [ "$backup_files_directory" == "" ]; then
        Aborting "backup_files_directory is null"
    fi

    if [ ! -d "$backup_files_directory" ]; then
        mkdir -p "$backup_files_directory"
        if [ $? ne 0 ]; then
            Aborting "failed to create backup file directory $backup_files_directory" 4
        fi
    fi

    Debug_Variable backup_files_directory 13

    local backup_file
    for backup_file in $backup_files; do
        Debug_Variable backup_file 12
        if [ -d "$backup_file" ]; then continue; fi
        if [ -f "$backup_file" ]; then
            local backup_file_basename=$(basename "$backup_file")
            local backup_file_dirname=$(dirname "$backup_file")
            Debug_Variable backup_file_basename 13
            Debug_Variable backup_file_dirname 13

            backup_file_last=$(find $backup_files_directory -name "$backup_file_basename\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.[0-9]*" | sort -n | tail -1)
            if [ "$backup_file_last" != "" ] && [ -f "$backup_file_last" ] && [ -f "$backup_file" ]; then
                Debug_Variable backup_file_last 3
                diff "$backup_file" "$backup_file_last" &> /dev/null
                if [ $? -eq 0 ]; then
                    Debug "validated backup $backup_file_last" 1
                    continue
                fi
            fi

            local -i backup_file_counter=0
            while [ -f "$backup_file_name" ] || [ "$backup_file_name" == "" ]; do
                let backup_file_counter=$backup_file_counter+1
                backup_file_name="$backup_files_directory/$backup_file_basename.$UNIQ.$backup_file_counter"
            done
            Debug_Variable backup_file_name 13

            /usr/bin/cp -f "$backup_file" "$backup_file_name"
            if [ $? -ne 0 ]; then
                Aborting "failed to backup $backup_file"
            else
                echo "created backup $backup_file_name"
            fi
        else
            Warning "$backup_file is missing"
        fi
    done

    # end function logic

    Debug_Function $@
}

function Base() {

    # begin function logic

    echo 1

    # end function logic

}

function Debug() {

    # begin function logic

    local debug_identifier_minimum_width="           "
    local debug_funcname_minimum_width="                                 "
    local machine_name_minimum_width="            "
    local step_minimum_width="   "

    local debug_message="$1"
    local -i debug_level="$2"
    local debug_function_name="$3"
    local -i debug_output=0

    if [ "$DEBUG" == "" ]; then DEBUG=0; fi


    if [ "$debug_function_name" == "" ] && [ "$DEBUG_FUNCTION_NAME" != "" ]; then
        debug_function_name=$DEBUG_FUNCTION_NAME
    else
        # automatically determine the caller
        local debug_caller_name=""
        local -i caller_frame=0
        while [ $caller_frame -lt 10 ]; do
            local debug_caller=$(caller $caller_frame)
            ((caller_frame++))

            if [ "$debug_caller" == "" ]; then break; fi

            # do not echo any output for these callers
            if [[ $debug_caller == *List* ]]; then continue; fi

            # omit these callers
            if [[ $debug_caller == *Debug* ]]; then continue; fi
            if [[ $debug_caller == *Question* ]]; then continue; fi
            if [[ $debug_caller == *Step* ]]; then continue; fi

            local debug_caller_name=${debug_caller% *}
            local debug_caller_name=${debug_caller_name#* }
            if [ "$debug_caller_name" != "" ]; then break; fi
        done
        local debug_function_name=$debug_caller_name
    fi


    # is DEBUG_FLAG really necessary?
    #if [ $DEBUG_FLAG -gt 0 ]; then
    if [ $DEBUG -ge $debug_level ]; then
        local -i debug_output=1
    fi
    #fi

    # DEBUG_FLAG -le 0
    if [ $debug_level -eq 0 ]; then
        # any Debug with a level of zero; message will be displayed
        local -i debug_output=1
    fi

    if [ $debug_output -eq 1 ]; then

        # set the color, if applicable
        if [ "$TERM" == "ansi" ] || [[ "$TERM" == *"color" ]] || [[ "$TERM" == *"xterm" ]]; then
            if [ $debug_level -eq 0 ]; then printf "%s" "$(tput sgr0)"; fi # reset
            if [ $debug_level -eq 1 ]; then printf "%s" "$(tput bold)$(tput setaf 7)"; fi # bold while
            if [ $debug_level -eq 2 ]; then printf "%s" "$(tput setaf 6)"; fi # cyan
            if [ $debug_level -eq 3 ]; then printf "%s" "$(tput setaf 5)"; fi # purple
            if [ $debug_level -eq 4 ]; then printf "%s" "$(tput setaf 4)"; fi # blue
            if [ $debug_level -eq 5 ]; then printf "%s" "$(tput setaf 3)"; fi # yellow
            if [ $debug_level -eq 6 ]; then printf "%s" "$(tput setaf 2)"; fi # green
            if [ $debug_level -eq 7 ]; then printf "%s" "$(tput setaf 1)"; fi # red
            if [ $debug_level -eq 8 ]; then printf "%s" "$(tput bold)$(tput setaf 1)"; fi # bold red
            if [ $debug_level -eq 9 ]; then printf "%s" "$(tput bold)$(tput setaf 1)"; fi # underlined bold red
            if [ $debug_level -ge 10 ] && [ $debug_level -le 99 ]; then printf "%s" "$(tput setab 3)$(tput setaf 7)"; fi # white on blue
            if [ $debug_level -eq 99 ]; then printf "%s" "$(tput setab 4)$(tput setaf 7)"; fi # white on blue
            if [ $debug_level -ge 100 ] && [ $debug_level -le 200 ]; then printf "%s" "$(tput setab 4)$(tput setaf 7)"; fi # white on blue
            if [ $debug_level -eq 1000 ]; then printf "%s" "$(tput sgr0)$(tput smso)"; fi # standout mode
        fi

        # display the appropriate message
        local debug_identifier="DEBUG [$debug_level]"
        if [ "$debug_function_name" != "" ] && [ $DEBUG -gt 3 ]; then
            printf "%s%s : %s%s : %s()%s : %s\n" "$debug_identifier" "${debug_identifier_minimum_width:${#debug_identifier}}" "${MACHINE_NAME}" "${machine_name_minimum_width:${#MACHINE_NAME}}" "${debug_function_name}" "${debug_funcname_minimum_width:${#debug_function_name}}" "$debug_message$(tput sgr0)"
        else
            printf "%s%s : %s%s : %s\n" "$debug_identifier" "${debug_identifier_minimum_width:${#debug_identifier}}" "${MACHINE_NAME}" "${machine_name_minimum_width:${#MACHINE_NAME}}" "$debug_message$(tput sgr0)"
        fi

        # reset the color, if applicable
        if [ "$TERM" == "ansi" ] || [[ "$TERM" == *"color" ]] || [[ "$TERM" == *"xterm" ]]; then
            printf "%s" "$(tput sgr0)"
        fi
    fi

    unset DEBUG_FUNCTION_NAME

    # end function logic

}

function Debug_Color() {

    # begin function logic

    if [ $DEBUG -lt 1000 ]; then return; fi # this function provides little value to an end user

    local color column line

    printf "Standard 16 colors\n"
    for ((color = 0; color < 17; color++)); do
        printf "|%s%3d%s" "$(tput setaf "$color")" "$color" "$(tput sgr0)"
    done
    printf "|\n\n"

    printf "Colors 16 to 231 for 256 colors\n"
    for ((color = 16, column = line = 0; color < 232; color++, column++)); do
        printf "|"
        ((column > 5 && (column = 0, ++line))) && printf " |"
        ((line > 5 && (line = 0, 1)))   && printf "\b \n|"
        printf "%s%3d%s" "$(tput setaf "$color")" "$color" "$(tput sgr0)"
    done
    printf "|\n\n"

    printf "Greyscale 232 to 255 for 256 colors\n"
    for ((; color < 256; color++)); do
        printf "|%s%3d%s" "$(tput setaf "$color")" "$color" "$(tput sgr0)"
    done
    printf "|\n"

    # end function logic

}

function Debug_Function() {

    # begin function logic

    local debug_caller=$(caller 0)
    local debug_caller_name=${debug_caller% *}
    local debug_caller_name=${debug_caller_name#* }

    if [ "$debug_caller_name" != "" ]; then
        local debug_function_name=$debug_caller_name
    else
        local debug_function_name="UNKNOWN"
    fi

    local debug_function_switch=DEBUG_FUNCTION_NAME_$debug_function_name

    if [ "$DEBUG_FUNCTION_NAME" == "" ]; then
        DEBUG_FUNCTION_NAME="main"
    fi

    if [ "${!debug_function_switch}" == "on" ]; then
        local debug_function_status="finished"
        unset ${debug_function_switch}
    else
        local debug_function_status="started"
        export ${debug_function_switch}="on"
    fi

    local debug_function_message="$debug_function_status function $debug_function_name() $@"
    #local debug_function_message="${debug_function_message%"${debug_function_message##*[![:space:]]}"}" # trim trailing spaces

    if [[ "$debug_function_name" == Debug* ]]; then
        local debug_function_level=1000 # only Debug_Function Debug_ functions at an extremely high level
    else
        local debug_function_level=100
    fi

    Debug "$debug_function_message" $debug_function_level $debug_function_name

    # end function logic

}

function Debug_Separator() {

    # begin function logic

    local separator_character="$1"
    local -i debug_level="$2"
    local -i separator_length="$3"

    if [ "$separator_character" == "" ]; then separator_character="="; fi
    if [ $separator_length -eq 0 ]; then separator_length=80; fi

    local separator=""
    while [ $separator_length -gt 0 ]; do
        local separator+=$separator_character
        local -i separator_length=$((separator_length-1))
    done

    Debug $separator $debug_level

    # end function logic

}

function Debug_Variable() {

    # begin function logic

    local variable_name=$1
    local -i debug_level="$2"
    local variable_comment="$3"

    local variable_value=${!variable_name}
    if [ "$variable_value" == "" ]; then variable_value="NULL"; fi

    # manual padding; call Debug() to display it
    local -i variable_pad=25 # the character position to pad to
    local -i variable_padded=0
    local -i variable_length=${#variable_name}
    local -i variable_position=$variable_pad-$variable_length

    while [ $variable_padded -le $variable_position ]; do
        local variable_name+=" "
        local -i variable_padded=$((variable_padded+1))
    done

    if [ "$DEBUG" == "" ]; then DEBUG=0; fi
    if [ "$variable_comment" != "" ]; then variable_value+=" ($variable_comment)"; fi

    Debug "$variable_name = $variable_value" $debug_level

    # end function logic

}

# List functions should not produce any output other than the list (i.e. do NOT use Debug(), Debug_Function, etc)
function List_Unique() {

    # begin function logic

    local INPUT_LIST="$1"
    if [ "$INPUT_LIST" == "" ]; then return; fi

    # set the list separating character
    local SEP="$2"
    if [ "$SEP" == "" ]; then SEP=":space:"; fi
    if [ "$SEP" == " " ]; then SEP=":space:"; fi

    echo "$INPUT_LIST" | awk -v RS='[['$SEP']]+' '!a[$0]++{printf "%s%s", $0, RT}' | sed -e '/^ */s///g' -e '/ *$/s///g'

    # end function logic

}

function Options() {
    Debug_Function $@

    # begin function logic

    # because the arguments get shifted each time, make sure to set and use a previously declared variable
    local -i total_arguments=$#

    # for each command line argument, evaluate them case by case, process them, and shift to the next
    local -i argument
    for ((argument=1; argument <= $total_arguments; argument++)); do
        case "$1" in
            --D | -D | --debug | -debug)
                OPTION=1
                DEBUG_FLAG=1
                DEBUG="$2"
                if [ "$DEBUG" != "" ] && [ ${DEBUG:0:1} == "-" ]; then
                    DEBUG=""
                fi
                if [ "$DEBUG" == "" ]; then
                    declare -i DEBUG=0
                    Debug "$1 flag was set" 0
                else
                    declare -i DEBUG=$2
                    Debug_Variable DEBUG 4 "$1 flag was set"
                    shift
                fi
                ;;
            --H | -H | --help | -help | --usage | -usage)
                OPTION=1
                Debug "$1 flag was set" 4
                Usage
                ;;
            --verbose | -verbose)
                OPTION=1
                VERBOSE_FLAG=1
                Debug "$1 flag was set" 4
                ;;
            --V | -V | --version | -version)
                OPTION=1
                echo "$BASE_0 (base) version $VERSION"
                exit
                ;;
        esac
        shift
    done

    # end function logic

    Debug_Function $@
}

function Question() {
    Debug_Function $@

    # begin function logic

    local question_message=""
    if [ "$MACHINE_NAME" != "" ]; then local question_message+="$MACHINE_NAME : "; fi
    local question_message+="$1"

    if [ "$YES_FLAG" == "" ]; then YES_FLAG=0; fi

    QUESTION_FLAG=0
    if [ $YES_FLAG -eq 1 ]; then
        QUESTION_FLAG=1
    else
        declare -l Y_N_Q=""
        echo
        echo -n "$question_message [y/n/q] ? "
        read Y_N_Q
        echo
        if [ "${Y_N_Q:0:1}" == "q" ]; then Stop 1; fi
        if [ "${Y_N_Q:0:1}" == "y" ]; then
            QUESTION_FLAG=1
        fi
        Y_N_Q=""
    fi

    # end function logic

    Debug_Function $@
}

function Require_Include() {
    Debug_Function $@

    # begin function logic

    include_file="$1"

    if [ "$include_file" == "" ]; then
        Aborting "null include file not found" 2
    fi

    include_found=0
    include_paths="$(dirname $BASE_0) $(pwd)"
    for include_path in $include_paths; do
        if [ $include_found -eq 1 ]; then break; fi
        while [ ! -z "$include_path" ]; do
            if [ "$include_path" == "." ]; then include_path=$(pwd -L .); fi
            if [ "$include_path" == "/" ]; then break; fi
            if [ -r "$include_path/include/$include_file" ] && [ ! -d "$include_path/include/$include_file" ]; then
                include_found=1
                source "$include_path/include/$include_file"
                Debug "sourced $include_path/include/$include_file" 5
                unset include_path include_file
                break
            else
                include_path=$(dirname "$include_path")
            fi
        done
    done
    if [ $include_found -ne 1 ]; then Aborting "$include_file include file not found" 1; fi

    # end function logic

    Debug_Function $@
}

function Start() {
    Debug_Function $@

    # begin function logic

    Debug "$BASE_0 started" 101

    Debug_Color

    #Debug_Variable "ARGUMENTS" 101
    BASE_SETS=$(set | grep ^BASE | grep = | awk -F= '{print $1}'| sort -u)
    for BASE_SET in $BASE_SETS; do
        Debug_Variable ${BASE_SET} 25
    done
    Debug_Variable "BASH_ARGC" 101
    Debug_Variable "BASH_LINENO" 101
    Debug_Variable "BASH_SOURCE" 101
    Debug_Variable "DEBUG" 101
    Debug_Variable "HERE" 101
    Debug_Variable "LOCKFILE" 101
    MACHINE_SETS=$(set | grep ^MACHINE | grep = | awk -F= '{print $1}'| sort -u)
    for MACHINE_SET in $MACHINE_SETS; do
        Debug_Variable ${MACHINE_SET} 25
    done
    Debug_Variable "PATH" 101
    Debug_Variable "SSH" 101
    SVN_SETS=$(set | grep ^SVN | grep = | awk -F= '{print $1}'| sort -u)
    for SVN_SET in $SVN_SETS; do
        Debug_Variable ${SVN_SET} 25
    done
    Debug_Variable "TMPFILE" 101
    Debug_Variable "UNIQ" 101
    Debug_Variable "USER" 101
    Debug_Variable "WHO" 101
    Debug_Variable "WHO_IP" 101

    # end function logic

    Debug_Function $@
}

function Step() {
    Debug_Function $@

    # begin function logic

    let STEP=$STEP+1

    local machine_name_minimum_width="            "
    local step_minimum_width="   "

    local time_stamp=$(date)
    if [ $STEP -gt 0 ]; then
        printf "%s : %s%s : step %s%s : %s\n" "$time_stamp" "${MACHINE_NAME}" "${machine_name_minimum_width:${#MACHINE_NAME}}" "$STEP" "${step_minimum_width:${#STEP}}" "$1"
    else
        printf "%s : %s%s : %s\n" "$time_stamp" "${MACHINE_NAME}" "${machine_name_minimum_width:${#MACHINE_NAME}}" "$1"
    fi

    # end function logic

    Debug_Function $@
}

function Step_Verbose() {
    Debug_Function $@

    # begin function logic

    if [ $VERBOSE_FLAG -gt 0 ]; then
        Step "$@"
    fi

    # end function logic

    Debug_Function $@
}

function Stop() {
    Debug_Function $@

    # begin function logic

    local -i return_code="$1"

    STEP=0

    if [ -f "$TMPFILE" ]; then
        rm "$TMPFILE"
    fi

    cd "$HERE"

    Debug "$BASE_0 finished in $SECONDS seconds" 101

    # end function logic

    Debug_Function $@

    exit $return_code
}

function System_Log() {
    Debug_Function $@

    # begin function logic

    local log_message="$1"
    if [ "$log_message" != "" ]; then
        echo "$log_message" | xargs logger -t "$(basename $BASE_0) : $WHO : $WHO_IP : $LOGNAME : $PWD " --
    fi

    # end function logic

    Debug_Function $@
}

# Upgrade "this (file)" "to/from (list of directories)"; automatically chooses the 'newest' file
function Upgrade() {
    Debug_Function $@

    # begin function logic

    if [ $# -ne 2 ]; then
        Debug "incorrect number of arguments, doing nothing" 102
        return
    fi

    local upgrade_file="$1"
    if [ "$upgrade_file" == "" ]; then local upgrade_file="$BASE_0"; fi
    #if [ "$upgrade_file" == "$BASH_SOURCE" ]; then DEBUG_FLAG=1; DEBUG=10; fi

    if [ "$upgrade_file" == "" ]; then
        Debug "null upgrade_file, doing nothing" 1
        return
    fi

    if [ ! -f "$upgrade_file" ]; then
        Debug "$upgrade_file is not a file, doing nothing" 102
        return
    fi

    local upgrade_basename=$(basename $upgrade_file)
    local upgrade_dirname=$(dirname $upgrade_file)
    Debug_Variable "upgrade_basename" 101
    Debug_Variable "upgrade_dirname" 101

    local upgrade_list="$2"

    if [ "$upgrade_list" == "" ]; then
        Debug "null upgrade_list, doing nothing" 1
        return
    fi

    local upgrade_list+=" $upgrade_dirname"
    local upgrade_list=$(List_Unique "$upgrade_list")
    Debug_Variable "upgrade_list" 101

    local upgrade_dirs=""
    for upgrade_check in $upgrade_list; do
        Debug_Variable "upgrade_check" 11
        if [ -d "$upgrade_check" ]; then
            upgrade_dirs+="$upgrade_check "
            continue
        fi

        if [ -f "$upgrade_check" ]; then
            local upgrade_check_dirname=$(dirname $upgrade_check)
            if [ -d "$upgrade_check_dirname" ]; then
                upgrade_dirs+="$upgrade_check_dirname "
                continue
            fi
        fi

    done
    local upgrade_dirs=$(List_Unique "$upgrade_dirs")
    Debug_Variable "upgrade_dirs" 101

    # determine the 'newest' file (it may not be upgrade_file)
    local upgrade_epochs=()

    local upgrade_dir=""
    for upgrade_dir in $upgrade_dirs; do
        if [ -f $upgrade_dir/$upgrade_basename ]; then
            local upgrade_file_date=$(stat $upgrade_dir/$upgrade_basename | grep ^Modify | cut -c 9-)
            local -i upgrade_file_epoch=$(date -d "$upgrade_file_date" +%s)
            upgrade_epochs+=("$upgrade_file_epoch,$upgrade_dir/$upgrade_basename")
        fi
    done
    Debug_Variable "upgrade_epochs" 101

    local upgrade_epochs_sort_n=($(for each in ${upgrade_epochs[@]}; do echo $each; done | sort -n))
    #echo "upgrade_epochs       =${upgrade_epochs[@]}"
    #echo "upgrade_epochs_sort_n=${upgrade_epochs_sort_n[@]}"

    local upgrade_epoch=${upgrade_epochs_sort_n[@]-1}
    #local upgrade_epoch=${upgrade_epochs_sort_n%%* }
    Debug_Variable "upgrade_epoch" 101

    local upgrade_epoch_file=${upgrade_epoch##*,} # strip off the epoch time to get a reusable, named variable to work with
    Debug_Variable "upgrade_epoch_file" 101

    local -i upgraded=0
    local upgrade_dir=""
    for upgrade_dir in $upgrade_dirs; do
        if [ "$upgrade_dir/$upgrade_basename" == "$upgrade_epoch_file" ]; then continue; fi # don't copy the newest file over itself

        if [ ! -d "$upgrade_dir" ]; then
            mkdir -p "$upgrade_dir"
            local return_code=$?
            if [ $return_code -ne 0 ]; then Aborting "failed to mkdir -p '$upgrade_dir'" 1; fi
            continue
        fi

        diff -q "$upgrade_epoch_file" "$upgrade_dir/$upgrade_basename" &> /dev/null
        local return_code=$?
        if [ $return_code -ne 0 ]; then
            # they differ, so upgrade (copy) to the latest 'epoch' file ...
            /usr/bin/cp -fp "$upgrade_epoch_file" "$upgrade_dir/$upgrade_basename"
            local return_code=$?
            if [ $return_code -ne 0 ]; then Aborting "failed to copy '$upgrade_epoch_file' to '$upgrade_dir/$upgrade_basename'" 1; fi
            echo "upgraded $upgrade_dir/$upgrade_basename ..."
            local -i upgraded=1
        else
            Debug "no need to upgrade $upgrade_dir/$upgrade_basename" 11
            local -i upgraded=0
        fi

    done

    # end function logic

    Debug_Function $@

    if [ $upgraded -eq 1 ]; then
        if [ -x "$BASE_0" ]; then
            echo "restarting $BASE_0 $BASE_ARG ..."
            sync
            sleep 1
            exec $BASE_0 $BASE_ARG
            Stop 1
        fi
    fi
}

function Usage() {
    Debug_Function $@

    # begin function logic

    echo
    echo "usage: $BASE_0 <options>"
    echo
    echo "options:"
    echo
    echo "  -D | --debug [level]           = print debug messages (less than) [level]"
    echo "  -H | --help                    = print this message"
    echo "  -V | --version                 = print version"
    echo

    if [ "$1" != "" ]; then
        echo "NOTE: $1"
        echo
    fi

    # end function logic

    Debug_Function $@

    Stop 1
}

function Warning() {
    Debug_Function $@

    # begin function logic

    local warning_message="$1"
    local -i warning_sleep="$2"

    echo
    echo "WARNING !!!"
    echo "WARNING !!!  $warning_message"
    echo "WARNING !!!"
    echo

    if [ $warning_sleep -ne 0 ]; then
        echo -n "Pausing for $warning_sleep seconds. ("
        while [ $warning_sleep -gt 0 ]; do
            echo -n "$warning_sleep"
            if [ $warning_sleep -gt 1 ]; then echo -n " . "; fi
            sleep 1
            ((warning_sleep--))
        done
        echo ")"
    fi

    # end function logic

    Debug_Function $@
}

# Main Logic

# validate HOSTNAME
if [ "$HOSTNAME" == "" ]; then
    Aborting "can't determine HOSTNAME"
fi

# validate DATACENTER
declare -i DATACENTER_VALID=0

[ -n "$BASE_HOST_LOCALITY" ] && MACHINE_DATACENTER="$BASE_HOST_LOCALITY"
[ -z "$MACHINE_DATACENTER" ] && MACHINE_DATACENTER=$(echo $MACHINE_NAME | awk -F\. '{print $1}' | awk -F- '{print $1}' | cut -c -3)
for BASE_DATACENTER in $BASE_DATACENTERS; do
    if [ "$MACHINE_DATACENTER" == "$BASE_DATACENTER" ]; then
        DATACENTER_VALID=1
        break;
    fi
done
if [ $DATACENTER_VALID -eq 0 ]; then
    BASE_DATACENTER=""
    MACHINE_DATACENTER=""
fi

if [ -f /etc/machine ]; then
    for BASE_ENVIRONMENT_OVERRIDE in $BASE_ENVIRONMENTS; do
        if [ "$MACHINE_ENVIRONMENT_OVERRIDE" != "" ]; then continue; fi
        MACHINE_ENVIRONMENT_OVERRIDE=$(grep "^${BASE_ENVIRONMENT_OVERRIDE}$" /etc/machine)
    done
    if [ "$MACHINE_ENVIRONMENT_OVERRIDE" != "" ]; then
        MACHINE_ENVIRONMENT="$MACHINE_ENVIRONMENT_OVERRIDE"
    fi
    unset BASE_ENVIRONMENT_OVERRIDE
    unset MACHINE_ENVIRONMENT_OVERRIDE
fi

# validate ENVIRONMENT
declare -i ENVIRONMENT_VALID=0

for BASE_ENVIRONMENT in $BASE_ENVIRONMENTS; do
    if [ "$MACHINE_ENVIRONMENT" == "$BASE_ENVIRONMENT" ]; then
        ENVIRONMENT_VALID=1
        break;
    fi
done
if [ $ENVIRONMENT_VALID -eq 0 ]; then
    BASE_ENVIRONMENT=""
    MACHINE_ENVIRONMENT=""
fi

if [ $DATACENTER_VALID -eq 1 ] && [ $ENVIRONMENT_VALID -eq 0 ]; then
    BASE_ENVIRONMENT="prod"
    MACHINE_ENVIRONMENT="prod"
fi

# Upgrade "this (file)" "to/from (list of directories)"
Upgrade $BASH_SOURCE "/usr/local/include $BASE_DIR/include"

# bash mandatory; enable all globbing
set +f
