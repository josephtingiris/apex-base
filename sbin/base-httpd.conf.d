#e!/bin/bash

# This script will ... check & conform directories to base httpd.conf.d sematics

# For coding conventions, organization, standards, & references, see: /base/README

INCLUDE_FILE="base.bash"
INCLUDE_FOUND=0
INCLUDE_PATHS="$(dirname $0) $(pwd)"

for INCLUDE_PATH in $INCLUDE_PATHS; do
    if [ $INCLUDE_FOUND -eq 1 ]; then break; fi

    while [ ! -z "$INCLUDE_PATH" ]; do
        if [ "$INCLUDE_PATH" == "." ]; then INCLUDE_PATH=$(pwd -L .); fi
        if [ "$INCLUDE_PATH" == "/" ]; then break; fi
        if [ -r "$INCLUDE_PATH/include/$INCLUDE_FILE" ] && [ ! -d "$INCLUDE_PATH/include/$INCLUDE_FILE" ]; then
            INCLUDE_FOUND=1
            source "$INCLUDE_PATH/include/$INCLUDE_FILE"
            Debug "sourced $INCLUDE_PATH/include/$INCLUDE_FILE" 500
            unset INCLUDE_PATH INCLUDE_FILE
            break
        else
            INCLUDE_PATH=`dirname "$INCLUDE_PATH"`
        fi
    done
done
if [ $INCLUDE_FOUND -ne 1 ]; then echo "can't find $INCLUDE_FILE"; exit 1; fi

# GLOBAL_VARIABLES

DEFAULT_BASE_VHOST_DIRS=(certificate html include session)
DEFAULT_BASE_VHOST_IGNORES=(bin default.content content classes etc include includes legacy lib machine sbin views vendor)

DEFAULT_BASE_VHOST_OWNER=apache
DEFAULT_BASE_VHOST_GROUP=apache
DEFAULT_BASE_VHOST_MODE=0770

# explicit declarations

declare -x DEFAULT_DATE=`date +%Y%m%d`

declare -x VERSION="0.1";

CONFIG_FLAG=0
DOMAIN_NAME_FLAG=0
ETC_FLAG=0
FORCE_FLAG=0
IP_FLAG=0
MACHINE_FLAG=0
PERMS_FLAG=0
RECORD_FLAG=0
RECURSIVE_FLAG=0
RCS_FLAG=0
SEARCH_FLAG=0
UPDATE_FLAG=0
YES_FLAG=0

PERMS_SET=0

# Function_Names

function Base_Vhost_Reset_Globals() {
    # make sure to reset these!
    BASE_VHOST=""
    BASE_VHOST_ACCOUNT=""
    BASE_VHOST_BASENAME=""
    BASE_VHOST_CERTIFICATE_FILE=""
    BASE_VHOST_CERTIFICATE_FILE_CANDIDATE=""
    BASE_VHOST_CERTIFICATE_FILE_CANDIDATES=()
    BASE_VHOST_CERTIFICATE_CHAINFILE=""
    BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE=""
    BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATES=()
    BASE_VHOST_CERTIFICATE_KEYFILE=""
    BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE=""
    BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATES=()
    BASE_VHOST_CONFIG_FILE=""
    BASE_VHOST_CONFIG_FILE_LAST=""
    BASE_VHOST_CONFIG_FILE_MD5=""
    BASE_VHOST_DIRS=()
    BASE_VHOST_IGNORE=""
    BASE_VHOST_IGNORES=()
    BASE_VHOST_CUSTOM_LOG=""
    BASE_VHOST_CUSTOM_LOG_MATCH=""
    BASE_VHOST_DIR=""
    BASE_VHOST_DIRNAME=""
    BASE_VHOST_DOCUMENT_ROOT=""
    BASE_VHOST_DOMAIN_NAME=""
    BASE_VHOST_ERROR_LOG=""
    BASE_VHOST_ERROR_LOG_MATCH=""
    BASE_VHOST_ETC_HTTPD_CONF_D_DIRS=""
    BASE_VHOST_GROUP=""
    BASE_VHOST_HTTPD_CONF_D=""
    BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_443=""
    BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT=""
    BASE_VHOST_MODE=""
    BASE_VHOST_NO_DO_ALIASES=""
    BASE_VHOST_OWNER=""
    BASE_VHOST_PREFIX=""
    BASE_VHOST_PREFIX_ACCOUNT_LOG=""
    BASE_VHOST_PREFIX_CUSTOM_LOG=""
    BASE_VHOST_SERVER_ALIAS=""
    BASE_VHOST_SERVER_ALIASES=()
    BASE_VHOST_SERVER_ALIASES_UNIQUE=()
    BASE_VHOST_SERVER_IP=""
    BASE_VHOST_SERVER_NAME=""
    BASE_VHOST_VHOSTS_CUSTOM_80=""
    BASE_VHOST_VHOSTS_CUSTOM_443=""
    BASE_VHOST_VHOSTS_CUSTOM_FILES=()
    BASE_VHOST_SKIP=""
    BASE_VHOST_SVN_URL=""

    DO_CHILD_NAME=""
    DO_CHILD_NAMES=""
    DO_CHILD_NAMES_SQL=""
    DO_PARENT_ID=""
    DO_PARENT_SQL=""
}

function Base_Vhost_Echo() {
    local base_vhost_echo_message="$1"
    if [ "$base_vhost_echo_message" == "" ]; then
        base_vhost_echo_message="NULL"
    fi
    if [ $SEARCH_FLAG -eq 0 ]; then
        echo "[$BASE_VHOST_COUNT] [$BASE_VHOST_ACCOUNT] [$BASE_VHOST] ... $base_vhost_echo_message"
    fi
}

function Usage() {
    Debug_Function $@

    local note="$1"

    # begin function logic

    echo
    echo "usage: $0 <options>"
    echo
    echo "options:"
    echo
    # these are handled in base.bash; useful to know though ...
    echo "  -D | --debug [level]           = print debug messages (less than) [level]"
    echo "  -H | --help                    = print this message"
    echo "  -V | --version                 = print version"
    echo
    # these must be handled in this script; please keep usage messages accurate
    #echo "  --no                           = answer 'no' to all questions"
    echo "  -c | --config [name]           = update config from /*/etc/httpd.conf.d.[name]"
    echo "                                   note: a special keyword of 'last' exists for this option"
    echo "                                         if no [name] is given then 'last' is the default"
    echo "                                         using '--config last' will use the previous template httpd.conf.d was created with"
    echo
    echo "  -d | --domain-name <name>      = update config using domain <name> instead of what's automatically determined"
    echo "                                   note: a special keyword of 'last' exists for this option"
    echo
    echo "  -i | --ip <address>            = use ip <address> for VirtualHost bindings (default='*')"
    echo
    echo "  -l | --link                    = update symbolic links in /etc/httpd/conf.d"
    echo "  -m | --machine <name>          = update symbolic links in /base/machine/<name>/etc/httpd/conf.d"
    echo
    echo "  -f | --force                   = force updates"
    echo
    echo "  -p | --perms                   = update svn & file permissions for document root"
    echo
    echo "  -r | --record [environment]    = update ServerAlias records for the given [environments] (default='dev local qa stg')"
    echo "                                   note: a special keyword of 'prod' exists for this option"
    echo "                                         using '--record prod' will *NOT* produce the default dev, local, qa, & stg ServerAliases"
    echo
    echo "  -s | --search                  = search for --domain-name <name> in httpd.conf.d files"
    echo
    echo "  -u | --update                  = update everything (except config)"
    echo
    echo "  -x | --recursive               = run recusively from $(pwd)"
    echo
    echo "  -y | --yes                     = answer 'yes' to all questions"
    echo

    if [ "$note" != "" ]; then
        echo "NOTE: $note"
        echo
    fi

    # end function logic

    Debug_Function $@

    Stop 1
}

# Validation Logic

# Options Logic

# call the base Options function (to process --debug, -debug, --help, -help, --usage, -usage, --verbose, -verbose)
Options $@

# expand upon the base Options function (careful, same named switches will be processed twice)

# for each command line argument, evaluate them case by case, process them, and shift to the next

for ((ARGUMENT=1; ARGUMENT <= $ARGUMENTS_TOTAL; ARGUMENT++)); do
    case "$1" in
        -c | --config | -config)
            CONFIG_FLAG=1
            CONFIG="$2"
            if [ "$CONFIG" != "" ] && [ ${CONFIG:0:1} == "-" ]; then
                CONFIG=""
            fi
            if [ "$CONFIG" != "" ]; then
                declare CONFIG=$2
                Debug_Variable CONFIG 4 "$1 flag was set"
                shift
            fi
            ;;
        -d | --domain-name | -domain-name)
            DOMAIN_NAME_FLAG=1
            DOMAIN_NAME="$2"
            if [ "$DOMAIN_NAME" != "" ] && [ ${DOMAIN_NAME:0:1} == "-" ]; then
                DOMAIN_NAME=""
            fi
            if [ "$DOMAIN_NAME" == "" ]; then
                Usage "$1 requires an argument"
            else
                declare DOMAIN_NAME=$2
                Debug_Variable DOMAIN_NAME 4 "$1 flag was set"
                shift
            fi
            ;;
        -i | --ip | -ip)
            IP_FLAG=1
            IP="$2"
            if [ "$IP" != "" ] && [ ${IP:0:1} == "-" ]; then
                IP=""
            fi
            if [ "$IP" == "" ]; then
                Usage "$1 requires an argument"
            else
                declare IP=$2
                Debug_Variable IP 4 "$1 flag was set"
                shift
            fi
            ;;
        -l | --link | -link)
            ETC_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -l | --link | -link)
            ETC_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -m | --machine | -machine)
            MACHINE_FLAG=1
            MACHINE="$2"
            if [ "$MACHINE" != "" ] && [ ${MACHINE:0:1} == "-" ]; then
                MACHINE=""
            fi
            if [ "$MACHINE" == "" ]; then
                Usage "$1 requires an argument"
            else
                declare MACHINE=$2
                Debug_Variable MACHINE 4 "$1 flag was set"
                shift
            fi
            ;;
        -f | --force | -force)
            FORCE_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -p | --perm | -perm | --perms | -perms)
            PERMS_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -r | --record | -record)
            RECORD_FLAG=1
            declare -l RECORD="$2"
            if [ "$RECORD" != "" ] && [ ${RECORD:0:1} == "-" ]; then
                RECORD=""
            fi
            if [ "$RECORD" != "" ]; then
                declare RECORD=$2
                Debug_Variable RECORD 4 "$1 flag was set"
                shift
            fi
            ;;
        -s | --search | -search)
            SEARCH_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -e | --etc | -etc)
            ETC_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -u | --update | -update)
            UPDATE_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -x | --recursive | -recursive)
            RECURSIVE_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        -y | --yes | -yes)
            YES_FLAG=1
            Debug "$1 flag was set" 4
            ;;
        *)
            # unknown flags
            if [ "$1" != "" ] && [ $OPTION -eq 0 ]; then
                echo "unknown flag '$1'"
                Stop 2 # not absolutely necessary, but does enforce proper usage
            fi
            ;;
    esac
    shift
done

#echo "ARGUMENTS=$ARGUMENTS"

# e.g., if there are no arguments, echo a usage message and/or exit
if [ $ARGUMENTS_TOTAL -eq 0 ]; then Usage; fi

# Main Logic

Start

Dependency "apachectl apex-data sed svn tr"

# do something

# set all flags if -u is given
if [ $UPDATE_FLAG -eq 1 ]; then
    ETC_FLAG=1
    MACHINE_FLAG=1
    PERMS_FLAG=1
fi

# export this so svn works without warnings
export WHO=$WHO

if [ "$RECORD" == "" ]; then
    SERVER_ALIAS_RECORDS="dev local qa stg"
    RECORD=$SERVER_ALIAS_RECORDS
else
    SERVER_ALIAS_RECORDS="$RECORD"
fi

if [ $CONFIG_FLAG -eq 1 ]; then

    Debug_Variable BASE_ENVIRONMENT 30
    Debug_Variable MACHINE_ENVIRONMENT 30

    if [ "$CONFIG" == "" ]; then
        CONFIG="last"
    fi

    CONFIG_FILES=("$(readlink -f $(pwd))/httpd.conf.d.$CONFIG" "${BASE_DIR_ACCOUNT}/$BASE_ACCOUNT/etc/httpd.conf.d.$CONFIG" "${BASE_DIR}/etc/httpd.conf.d.$CONFIG")

    for CONFIG_FILE in ${CONFIG_FILES[@]}; do
        if [ -s "$CONFIG_FILE" ]; then
            break;
        else
            CONFIG_FILE=""
        fi
    done
    Debug_Variable CONFIG_FILE 10

    if [ "$CONFIG" != "" ] && [ -r "$CONFIG" ] && [ "$CONFIG_FILE" == "" ]; then
        CONFIG_FILE="$CONFIG"
    fi

    if [ "$CONFIG" == "dyanmic" ] || [ "$CONFIG" == "last" ]; then
        CONFIG_FILE="dynamic"
        CONFIG_FILE_MD5="md5sum"
    else
        if [ "$CONFIG_FILE" == "" ]; then
            Aborting "CONFIG_FILE is empty" 1
        fi
        if [ ! -r "$CONFIG_FILE" ]; then
            Aborting "$CONFIG_FILE file not found" 1
        else
            CONFIG_FILE_MD5=$(md5sum "$CONFIG_FILE" | awk '{print $1}')
        fi
    fi

    echo
    echo $(date)
    echo
    echo "Template $CONFIG_FILE ($CONFIG_FILE_MD5) ... [OK]"
fi

if [ $RECURSIVE_FLAG -eq 1 ]; then
    # default is NOT to recurse
    FIND_DEPTH=""
else
    FIND_DEPTH="-maxdepth 1"
fi

if [ $SEARCH_FLAG -eq 0 ]; then
    echo
    if [ "$FIND_DEPTH" == "" ]; then
        echo "Searching $HERE for all potentially valid base document roots ... [OK]"
    else
        echo "Checking $HERE for valid base document root ... [OK]"
        if [ $RECURSIVE_FLAG -eq 0 ]; then
            if [ $CONFIG_FLAG -eq 1 ]; then
                if [ $YES_FLAG -eq 1 ]; then
                    touch httpd.conf.d
                fi
            fi
        fi
    fi
fi

# base virtual host *should* have an html directory and an accompanying httpd.conf.d file; find either or
# create (and subsequently unique) an array of vhost directories; exclude nested html directories
BASE_VHOSTS=()

while read BASE_VHOST; do
    BASE_VHOST=$(echo "$BASE_VHOST" | sed -e '/\/$/s///g')
    Debug_Variable BASE_VHOST 3 read
    BASE_VHOST_BASENAME=$(basename "$BASE_VHOST")
    Debug_Variable BASE_VHOST_BASENAME 3
    BASE_VHOST_DIRNAME=$(dirname "$BASE_VHOST")
    Debug_Variable BASE_VHOST_DIRNAME 3

    if [ "$BASE_VHOST_BASENAME" == "httpd.conf.d" ]; then
        if [ -d "$BASE_VHOST_DIRNAME" ]; then
            Debug_Variable BASE_VHOST 30 dirname
            BASE_VHOSTS+=("$BASE_VHOST_DIRNAME")
        fi
    else
        if [ -d "$BASE_VHOST" ]; then
            Debug_Variable BASE_VHOST 30 dirname
            BASE_VHOSTS+=("$BASE_VHOST")
        fi
    fi

    Base_Vhost_Reset_Globals
done <<< "$(find ${HERE}/ $FIND_DEPTH -type f -name httpd.conf.d -o -type d -name html | awk -Fhtml '{print $1}')"

BASE_VHOSTS_UNIQUE=$(echo "${BASE_VHOSTS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
BASE_VHOSTS=(${BASE_VHOSTS_UNIQUE[@]})

BASE_VHOST_COUNT=0

for BASE_VHOST in "${BASE_VHOSTS[@]}"; do
    Debug_Variable BASE_VHOST 9

    # this is a workaround for the base filesystem & mae product structure; /content*/html appears lots of places
    # need to revisit this; maybe use another directory name for content/html ???
    BASE_VHOST_CONTINUE=0

    if [ "$BASE_VHOST_IGNORES" == "" ]; then
        Debug "DEFAULT_BASE_VHOST_IGNORES = $(echo ${DEFAULT_BASE_VHOST_IGNORES[@]})" 20
        BASE_VHOST_IGNORES=(${DEFAULT_BASE_VHOST_IGNORES[@]})
    fi
    Debug "BASE_VHOST_IGNORES = $(echo ${BASE_VHOST_IGNORES[@]})" 20

    for BASE_VHOST_IGNORE in ${BASE_VHOST_IGNORES[@]}; do
        if [ $BASE_VHOST_CONTINUE -ne 0 ]; then continue; fi
        BASE_VHOST_SKIP=$(echo "$BASE_VHOST" | egrep -e "/${BASE_VHOST_IGNORE}$|/${BASE_VHOST_IGNORE}/")
        Debug_Variable BASE_VHOST_SKIP 5

        if [ $BASE_VHOST_CONTINUE -eq 0 ] && [ "$BASE_VHOST_SKIP" != "" ]; then
            Debug_Variable BASE_VHOST_IGNORE 5 "IGNORE $BASE_VHOST"
            BASE_VHOST_CONTINUE=1
        else
            Debug_Variable BASE_VHOST_IGNORE 5 "not in $BASE_VHOST"
        fi
    done
    if [ $BASE_VHOST_CONTINUE -ne 0 ]; then
        continue
    fi

    let BASE_VHOST_COUNT=$BASE_VHOST_COUNT+1

    if [ $SEARCH_FLAG -eq 1 ] && [ "$DOMAIN_NAME" != "" ]; then
        BASE_VHOST_HTTPD_CONF_D="${BASE_VHOST}/httpd.conf.d"
        if [ -s "${BASE_VHOST_HTTPD_CONF_D}" ]; then
            FOUND_SERVER_ALIAS=$(grep "ServerAlias ${DOMAIN_NAME}$" "${BASE_VHOST_HTTPD_CONF_D}"*)
            if [ "$FOUND_SERVER_ALIAS" != "" ]; then
                echo; echo "$DOMAIN_NAME is a ServerAlias in $BASE_VHOST_HTTPD_CONF_D"
            else
                FOUND_SERVER_IP=$(grep "<VirtualHost\ [0-9]" "$BASE_VHOST_HTTPD_CONF_D"* | awk -F: '{print $(NF-1)}' | awk '{print $NF}')
                if [ "$FOUND_SERVER_IP" != "" ]; then
                    echo; echo "$DOMAIN_NAME has a Server IP in $BASE_VHOST_HTTPD_CONF_D ($FOUND_SERVER_IP)"
                fi
                FOUND_SERVER_IP=""
                FOUND_SERVER_NAME=$(grep "ServerName ${DOMAIN_NAME}$" "$BASE_VHOST_HTTPD_CONF_D"*)
                if [ "$FOUND_SERVER_NAME" != "" ]; then
                    echo; echo "$DOMAIN_NAME is a ServerName in $BASE_VHOST_HTTPD_CONF_D"
                fi
                FOUND_SERVER_NAME=""
            fi
            FOUND_SERVER_ALIAS=""
        fi
        continue
    fi

    if [ -r "${BASE_VHOST}/httpd.conf.d.account.custom" ]; then
        BASE_VHOST_ACCOUNT=$(cat "${BASE_VHOST}/httpd.conf.d.account.custom" | grep -v ^# | head -1 | awk '{print $1}')
    else
        BASE_VHOST_ACCOUNT=$(apex-data "$BASE_VHOST" --account)
        if [ $? -ne 0 ] || [ "$BASE_VHOST_ACCOUNT" == "" ]; then
            Aborting "apex-data $BASE_VHOST --account failed"
        fi
    fi
    Debug_Variable BASE_VHOST_ACCOUNT 20

    if [ -r "${BASE_VHOST}/httpd.conf.d.documentroot.custom" ]; then
        BASE_VHOST_DOCUMENT_ROOT=$(cat "${BASE_VHOST}/httpd.conf.d.documentroot.custom" | grep -v ^# | head -1 | awk '{print $1}')
    else
        BASE_VHOST_DOCUMENT_ROOT=$(apex-data "$BASE_VHOST" --document-root)
        if [ $? -ne 0 ] || [ "$BASE_VHOST_DOCUMENT_ROOT" == "" ]; then
            Aborting "apex-data $BASE_VHOST --document-root failed"
        fi
    fi
    Debug_Variable BASE_VHOST_DOCUMENT_ROOT 20

    if [ -r "${BASE_VHOST}/httpd.conf.d.name.custom" ]; then
        BASE_VHOST_SERVER_NAME=$(cat "${BASE_VHOST}/httpd.conf.d.name.custom" | grep -v ^# | head -1 | awk '{print $1}')
    else
        BASE_VHOST_SERVER_NAME=$(apex-data "$BASE_VHOST" --server-name)
        if [ $? -ne 0 ] || [ "$BASE_VHOST_SERVER_NAME" == "" ]; then
            Aborting "apex-data $BASE_VHOST --server-name failed"
        fi
    fi
    Debug_Variable BASE_VHOST_SERVER_NAME 20

    if [ "$DOMAIN_NAME" == "" ]; then
        if [ -r "${BASE_VHOST}/httpd.conf.d.name.custom" ]; then
            BASE_VHOST_DOMAIN_NAME="${BASE_VHOST_SERVER_NAME#*.}" # everything after the first period
        else
            BASE_VHOST_DOMAIN_NAME=$(apex-data "$BASE_VHOST" --domain-name)
        fi
        if [ $? -ne 0 ] || [ "$BASE_VHOST_DOMAIN_NAME" == "" ]; then
            Aborting "apex-data $BASE_VHOST --domain-name failed"
        fi
    else
        BASE_VHOST_DOMAIN_NAME="$DOMAIN_NAME"
    fi
    Debug_Variable BASE_VHOST_DOMAIN_NAME 20

    if [ "$BASE_VHOST_ACCOUNT" != "" ] && [ "$BASE_VHOST_DOMAIN_NAME" != "" ]; then
        if [ "$(readlink -f $(pwd) | grep \/src\/)" != "" ] && [ "$(echo "$BASE_VHOST_DOMAIN_NAME" | grep \.src)" == "" ]; then
            BASE_VHOST_PREFIX="${BASE_VHOST_ACCOUNT}.${BASE_VHOST_DOMAIN_NAME}"
            BASE_VHOST_PREFIX+=".src"
        else
            BASE_VHOST_PREFIX="$(apex-data "$BASE_VHOST" --account).$BASE_VHOST_SERVER_NAME"
        fi
    else
        BASE_VHOST_PREFIX="$(apex-data "$BASE_VHOST" --account).$BASE_VHOST_SERVER_NAME"
        if [ $? -ne 0 ] || [ "$BASE_VHOST_PREFIX" == "" ]; then
            Aborting "apex-data $BASE_VHOST --account failed"
        fi
    fi
    Debug_Variable BASE_VHOST_PREFIX 9 $BASE_VHOST

    if [ -f "${BASE_VHOST}"/httpd.conf.d ]; then
        BASE_VHOST_SERVER_IP="$(grep "<VirtualHost\ " "${BASE_VHOST}/httpd.conf.d" | awk -F: '{print $(NF-1)}' | awk '{print $NF}' | sort -u)"
        Debug_Variable BASE_VHOST_SERVER_IP 20 "found"
    fi
    if [ "$BASE_VHOST_SERVER_IP" == "" ]; then
        BASE_VHOST_SERVER_IP="*"
        Debug_Variable BASE_VHOST_SERVER_IP 20 "set to wildcard"
    fi
    if [ "$IP" != "" ]; then
        if [ "$BASE_VHOST_SERVER_IP" != "$IP" ]; then
            Warning "$IP is not $BASE_VHOST_SERVER_IP"
            Question "Use $IP for $BASE_VHOST VirtualHost bindings"
            if [ "$QUESTION_FLAG" -eq 1 ]; then
                BASE_VHOST_SERVER_IP="$IP"
            fi
        fi
    fi

    if [ "$BASE_VHOST_VHOSTS_CUSTOM_80" == "" ] && [ -f "${BASE_VHOST}/httpd.conf.d.vhosts.custom.80" ]; then
        BASE_VHOST_VHOSTS_CUSTOM_80="include ${BASE_VHOST}/httpd.conf.d.vhosts.automatic.80"
        BASE_VHOST_VHOSTS_CUSTOM_FILES+=("${BASE_VHOST}/httpd.conf.d.vhosts.custom.80")
    else
        if [ "$BASE_VHOST_VHOSTS_CUSTOM_80" == "" ] && [ -f "${BASE_VHOST}/httpd.conf.d.vhosts.custom" ]; then
            BASE_VHOST_VHOSTS_CUSTOM_80="include ${BASE_VHOST}/httpd.conf.d.vhosts.automatic"
            if [ "${BASE_VHOST_VHOSTS_CUSTOM_FILES}" == "" ]; then
                BASE_VHOST_VHOSTS_CUSTOM_FILES+=("${BASE_VHOST}/httpd.conf.d.vhosts.custom")
            fi
        fi
    fi

    if [ "$BASE_VHOST_VHOSTS_CUSTOM_80" == "" ]; then
        BASE_VHOST_VHOSTS_CUSTOM_80="#include ${BASE_VHOST}/httpd.conf.d.vhosts.custom.80 file not found"
    fi

    if [ "$BASE_VHOST_VHOSTS_CUSTOM_443" == "" ] && [ -f "${BASE_VHOST}/httpd.conf.d.vhosts.custom.443" ]; then
        BASE_VHOST_VHOSTS_CUSTOM_443="include ${BASE_VHOST}/httpd.conf.d.vhosts.automatic.443"
        BASE_VHOST_VHOSTS_CUSTOM_FILES+=("${BASE_VHOST}/httpd.conf.d.vhosts.custom.443")
    else
        if [ "$BASE_VHOST_VHOSTS_CUSTOM_443" == "" ] && [ -f "${BASE_VHOST}/httpd.conf.d.vhosts.custom" ]; then
            BASE_VHOST_VHOSTS_CUSTOM_443="include ${BASE_VHOST}/httpd.conf.d.vhosts.automatic"
            if [ "${BASE_VHOST_VHOSTS_CUSTOM_FILES}" == "" ]; then
                BASE_VHOST_VHOSTS_CUSTOM_FILES+=("${BASE_VHOST}/httpd.conf.d.vhosts.custom")
            fi
        fi
    fi

    if [ "$BASE_VHOST_VHOSTS_CUSTOM_443" == "" ]; then
        BASE_VHOST_VHOSTS_CUSTOM_443="#include ${BASE_VHOST}/httpd.conf.d.vhosts.custom.443 file not found"
    fi

    Debug_Variable BASE_VHOST_VHOSTS_CUSTOM_80 20
    Debug_Variable BASE_VHOST_VHOSTS_CUSTOM_443 20
    Debug_Variable BASE_VHOST_VHOSTS_CUSTOM_FILES 20

    # start validating the directory, files, etc.

    echo

    Base_Vhost_Echo "[OK] found ServerName $BASE_VHOST_SERVER_NAME"
    Base_Vhost_Echo "[OK] found Server IP $BASE_VHOST_SERVER_IP"

    if [ -d "$BASE_VHOST" ]; then
        Debug "[OK] found vhost directory" 1
    else
        Base_Vhost_Echo "[ERROR] missing vhost directory"
    fi

    if [ "$BASE_VHOST_DIRS" == "" ]; then
        Debug "DEFAULT_BASE_VHOST_DIRS = $(echo ${DEFAULT_BASE_VHOST_DIRS[@]})" 20
        BASE_VHOST_DIRS=(${DEFAULT_BASE_VHOST_DIRS[@]})
        BASE_VHOST_PEER_DIRS=(config content etc files log logs nbproject surveys upload uploads vendor) # these may, or may not exist

            for BASE_VHOST_PEER_DIR in ${BASE_VHOST_PEER_DIRS[@]}; do
                if [ -d "${BASE_VHOST}/${BASE_VHOST_PEER_DIR}" ]; then
                    BASE_VHOST_DIRS+=(${BASE_VHOST_PEER_DIR})
                fi
            done
            BASE_VHOST_PEER_DIR=""
    fi
    Debug "BASE_VHOST_DIRS = $(echo ${BASE_VHOST_DIRS[@]})" 5

    Debug "BASE_VHOST_IGNORES = $(echo ${BASE_VHOST_IGNORES[@]})" 20

    for BASE_VHOST_DIR in ${BASE_VHOST_DIRS[@]}; do
        Debug_Variable BASE_VHOST_DIR 30
        if [ -d "${BASE_VHOST}/$BASE_VHOST_DIR" ] || [ -h "${BASE_VHOST}/$BASE_VHOST_DIR" ]; then
            Debug "[OK] found $BASE_VHOST_DIR directory" 1
        else
            Base_Vhost_Echo "[ERROR] missing $BASE_VHOST_DIR directory"
            if [ $UPDATE_FLAG -eq 1 ]; then
                Base_Vhost_Echo "[UPDATE] make $BASE_VHOST_DIR directory"
                mkdir -p "${BASE_VHOST}/${BASE_VHOST_DIR}"
                if [ $? -ne 0 ]; then
                    Base_Vhost_Echo "[WARNING] failed to mkdir $BASE_VHOST_DIR"
                    Base_Vhost_Reset_Globals
                    continue
                fi
                Base_Vhost_Echo "[UPDATE] svn add $BASE_VHOST_DIR directory"
                svn add "${BASE_VHOST}/${BASE_VHOST_DIR}" &> /dev/null
                if [ $? -ne 0 ]; then
                    Base_Vhost_Echo "[WARNING] failed to svn add $BASE_VHOST_DIR"
                    Base_Vhost_Reset_Globals
                    continue
                fi
            fi
        fi
    done

    if [ $PERMS_FLAG -eq 1 ]; then
        BASE_VHOST_SVN_URL=$(svn info 2> /dev/null | grep URL: | awk -FURL: '{print $NF}')

        if [ -f httpd.conf.d.permissions.custom ]; then
            source httpd.conf.d.permissions.custom
        else
            unset -v BASE_VHOST_OWNER BASE_VHOST_GROUP BASE_VHOST_MODE
        fi

        if [ "$BASE_VHOST_OWNER" == "" ]; then
            BASE_VHOST_OWNER=$DEFAULT_BASE_VHOST_OWNER
        fi
        if [ "$BASE_VHOST_GROUP" == "" ]; then
            BASE_VHOST_GROUP=$DEFAULT_BASE_VHOST_GROUP
        fi
        if [ "$BASE_VHOST_MODE" == "" ]; then
            BASE_VHOST_MODE=$DEFAULT_BASE_VHOST_MODE
        fi

        for BASE_VHOST_DIR in ${BASE_VHOST_DIRS[@]}; do
            Debug_Variable BASE_VHOST_DIR 10 PERMS_FLAG
            Base_Vhost_Echo "[UPDATE] svn propset $BASE_VHOST_DIR directory"
            svn propset owner "$BASE_VHOST_OWNER" "${BASE_VHOST}/${BASE_VHOST_DIR}" &> /dev/null
            if [ $? -eq 0 ]; then
                PERMS_SET=1
            fi
            svn propset group "$BASE_VHOST_GROUP" "${BASE_VHOST}/${BASE_VHOST_DIR}" &> /dev/null
            if [ $? -eq 0 ]; then
                PERMS_SET=1
            fi
            svn propset mode "$BASE_VHOST_MODE" "${BASE_VHOST}/${BASE_VHOST_DIR}" &> /dev/null
            if [ $? -eq 0 ]; then
                PERMS_SET=1
            fi
            IGNORE_PROPS=(log session tmp)

            for IGNORE_PROP in ${IGNORE_PROPS[@]}; do
                if [ "$BASE_VHOST_DIR" == "$IGNORE_PROP" ]; then
                    Base_Vhost_Echo "[UPDATE] svn ignore $BASE_VHOST_DIR directory"
                    svn propset svn:ignore "*" "${BASE_VHOST}/${BASE_VHOST_DIR}" &> /dev/null
                    if [ $? -eq 0 ]; then
                        PERMS_SET=1
                    fi
                    RCS_FLAG=1
                fi
            done
        done
        #Base_Vhost_Echo "[UPDATE] svn perms ${BASE_VHOST}"
        #svn perms "${BASE_VHOST}" &> /dev/null
        #echo
    fi

    BASE_VHOST_HTTPD_CONF_D="${BASE_VHOST}/httpd.conf.d"
    if [ ! -f "${BASE_VHOST_HTTPD_CONF_D}" ]; then
        if [ -s "${BASE_VHOST}/${BASE_ENVIRONMENT}.httpd.conf.d" ]; then
            Warning "${BASE_VHOST}/${BASE_ENVIRONMENT}.httpd.conf.d exists"
            # this needs work
            #BASE_VHOST_HTTPD_CONF_D="${BASE_VHOST}/${BASE_ENVIRONMENT}.httpd.conf.d"
            #SERVER_ALIAS_RECORDS="$BASE_ENVIRONMENT"
        fi
    fi
    Debug_Variable BASE_VHOST_HTTPD_CONF_D 20

    if [ $CONFIG_FLAG -eq 1 ]; then

        # these are oreder dependent; the first found will be used
        BASE_VHOST_CERTIFICATE_FILE_CANDIDATES=(
            "${BASE_VHOST}/certificate/ca.${BASE_VHOST_SERVER_NAME}.crt"
            "${BASE_VHOST}/certificate/ca.${BASE_VHOST_DOMAIN_NAME}.crt"
            "${BASE_VHOST}/certificate/ca.*.${BASE_VHOST_DOMAIN_NAME}.crt"
            "${BASE_VHOST}/certificate/*.${BASE_VHOST_DOMAIN_NAME}.crt"
            "${BASE_VHOST}/certificate/site.crt"
            "${BASE_VHOST}/certificate/ssl.crt"
            "${BASE_VHOST}/certificate/localhost.crt"
            "${BASE_VHOST}/certificate/ca.crt"
            /etc/pki/tls/certs/localhost.crt
            /etc/pki/tls/certs/ca.crt
        )

        for BASE_VHOST_CERTIFICATE_FILE_CANDIDATE in ${BASE_VHOST_CERTIFICATE_FILE_CANDIDATES[@]}; do
            if [ "$BASE_VHOST_CERTIFICATE_FILE" == "" ] && [ -s "$BASE_VHOST_CERTIFICATE_FILE_CANDIDATE" ]; then
                Debug_Variable BASE_VHOST_CERTIFICATE_FILE_CANDIDATE 2 found
                BASE_VHOST_CERTIFICATE_FILE="$BASE_VHOST_CERTIFICATE_FILE_CANDIDATE"
                break
            else
                Debug_Variable BASE_VHOST_CERTIFICATE_FILE_CANDIDATE 3 failed
            fi
        done

        if [ "$BASE_VHOST_CERTIFICATE_FILE" == "" ]; then
            BASE_VHOST_CERTIFICATE_FILE="#SSLCertificateFile NOT FOUND"
        else
            BASE_VHOST_CERTIFICATE_FILE="SSLCertificateFile ${BASE_VHOST_CERTIFICATE_FILE}"
        fi
        Debug_Variable BASE_VHOST_CERTIFICATE_FILE 10

        # these are oreder dependent; the first found will be used
        BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATES=(
            "${BASE_VHOST}/certificate/chain.${BASE_VHOST_SERVER_NAME}.crt"
            "${BASE_VHOST}/certificate/chain.${BASE_VHOST_DOMAIN_NAME}.crt"
            "${BASE_VHOST}/certificate/chain.*.${BASE_VHOST_DOMAIN_NAME}.crt"
            "${BASE_VHOST}/certificate/*.${BASE_VHOST_DOMAIN_NAME}.chain"
            "${BASE_VHOST}/certificate/chain.crt"
        )

        for BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE in ${BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATES[@]}; do
            if [ "$BASE_VHOST_CERTIFICATE_CHAINFILE" == "" ] && [ -s "$BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE" ]; then
                Debug_Variable BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE 20 found
                BASE_VHOST_CERTIFICATE_CHAINFILE="$BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE"
                break
            else
                Debug_Variable BASE_VHOST_CERTIFICATE_CHAINFILE_CANDIDATE 30 failed
            fi
        done

        if [ "$BASE_VHOST_CERTIFICATE_CHAINFILE" == "" ]; then
            BASE_VHOST_CERTIFICATE_CHAINFILE="#SSLCertificateChainFile NOT FOUND"
        else
            BASE_VHOST_CERTIFICATE_CHAINFILE="SSLCertificateChainFile ${BASE_VHOST_CERTIFICATE_CHAINFILE}"
        fi
        Debug_Variable BASE_VHOST_CERTIFICATE_CHAINFILE 10

        # these are oreder dependent; the first found will be used
        BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATES=(
            "${BASE_VHOST}/certificate/ca.${BASE_VHOST_SERVER_NAME}.key"
            "${BASE_VHOST}/certificate/ca.${BASE_VHOST_DOMAIN_NAME}.key"
            "${BASE_VHOST}/certificate/ca.*.${BASE_VHOST_DOMAIN_NAME}.key"
            "${BASE_VHOST}/certificate/*.${BASE_VHOST_DOMAIN_NAME}.key"
            "${BASE_VHOST}/certificate/site.key"
            "${BASE_VHOST}/certificate/ssl.key"
            "${BASE_VHOST}/certificate/localhost.key"
            "${BASE_VHOST}/certificate/ca.key"
            /etc/pki/tls/private/localhost.key
            /etc/pki/tls/private/ca.key
        )

        for BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE in ${BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATES[@]}; do
            if [ "$BASE_VHOST_CERTIFICATE_KEYFILE" == "" ] && [ -s "$BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE" ]; then
                Debug_Variable BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE 20 found
                BASE_VHOST_CERTIFICATE_KEYFILE="$BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE"
                break
            else
                Debug_Variable BASE_VHOST_CERTIFICATE_KEYFILE_CANDIDATE 30 failed
            fi
        done

        if [ "$BASE_VHOST_CERTIFICATE_KEYFILE" == "" ]; then
            BASE_VHOST_CERTIFICATE_KEYFILE="#SSLCertificateKeyFile NOT FOUND"
        else
            BASE_VHOST_CERTIFICATE_KEYFILE="SSLCertificateKeyFile ${BASE_VHOST_CERTIFICATE_KEYFILE}"
        fi
        Debug_Variable BASE_VHOST_CERTIFICATE_KEYFILE 10

        Debug_Variable BASE_VHOST_HTTPD_CONF_D 9
        Debug_Variable CONFIG 9
        Debug_Variable CONFIG_FILE 9

        if [ "$BASE_VHOST_HTTPD_CONF_D" != "" ] && [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
            BASE_VHOST_CONFIG_FILE_LAST=$(head -1 "$BASE_VHOST_HTTPD_CONF_D" | awk -Fmd5sum '{print $1}' | awk -F"#" '{print $NF}' | sed -e 's|[ \t]*$||g' -e 's|^[ \t]*||g')
            Debug_Variable BASE_VHOST_CONFIG_FILE_LAST 9
        else
            Base_Vhost_Echo "[WARNING] config is empty"
            if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
                if [ $FORCE_FLAG -eq 0 ]; then
                    Warning "skipping $BASE_VHOST_HTTPD_CONF_D (use --force)"
                    if [ $RECURSIVE_FLAG -eq 1 ]; then
                        Base_Vhost_Reset_Globals
                        continue
                    else
                        rm -f "$BASE_VHOST_HTTPD_CONF_D"
                        Aborting "manually remove $BASE_VHOST_HTTPD_CONF_D first, or use the --force flag"
                    fi
                else
                    Warning "forcing $BASE_VHOST_HTTPD_CONF_D to a new template ($CONFIG_FILE)"
                    BASE_VHOST_CONFIG_FILE="$CONFIG_FILE"
                fi
            else
                Aborting "$BASE_VHOST_HTTPD_CONF_D file not found"
            fi
        fi

        if [ "$CONFIG" == "dynamic" ] || [ "$CONFIG" == "last" ]; then
            if [ -r "$BASE_VHOST_CONFIG_FILE_LAST" ]; then
                BASE_VHOST_CONFIG_FILE="$BASE_VHOST_CONFIG_FILE_LAST"
            else
                BASE_VHOST_CONFIG_FILE_LAST=""
            fi
        fi

        if [ "$BASE_VHOST_CONFIG_FILE_LAST" == "" ]; then
            Base_Vhost_Echo "[WARNING] config was not generated from a valid template"
            if [ $FORCE_FLAG -eq 0 ]; then
                Warning "skipping $BASE_VHOST_HTTPD"
                if [ $RECURSIVE_FLAG -eq 1 ]; then
                    Base_Vhost_Reset_Globals
                    continue
                else
                    Aborting "refusing to change $BASE_VHOST_HTTPD_CONF_D, try the --force flag"
                fi
            else
                if [ -r "$CONFIG_FILE" ]; then
                    Warning "forcing $BASE_VHOST_HTTPD_CONF_D to a new template ($CONFIG_FILE)"
                    BASE_VHOST_CONFIG_FILE="$CONFIG_FILE"
                else
                    Warning "unable to force $BASE_VHOST_HTTPD_CONF_D to an unknown template ($CONFIG_FILE)"
                    BASE_VHOST_CONFIG_FILE=""
                    continue
                fi
            fi
        fi

        if [ "$BASE_VHOST_CONFIG_FILE" == "" ] && [ "$BASE_VHOST_CONFIG_FILE_LAST" != "$CONFIG_FILE" ]; then
            Base_Vhost_Echo "[WARNING] config was previously generated from a different template ($BASE_VHOST_CONFIG_FILE_LAST)"
            if [ $FORCE_FLAG -eq 0 ]; then
                Warning "skipping $BASE_VHOST_HTTPD_CONF_D"
                if [ $RECURSIVE_FLAG -eq 1 ]; then
                    Base_Vhost_Reset_Globals
                    continue
                else
                    Aborting "manually remove $BASE_VHOST_HTTPD_CONF_D first, or use the --force flag"
                fi
            else
                Warning "forcing $BASE_VHOST_HTTPD_CONF_D to a new template ($CONFIG_FILE)"
                BASE_VHOST_CONFIG_FILE="$CONFIG_FILE"
            fi
        else
            if [ "$BASE_VHOST_CONFIG_FILE" == "" ] && [ -r "$CONFIG_FILE" ]; then
                BASE_VHOST_CONFIG_FILE="$CONFIG_FILE"
            fi
        fi

        Debug_Variable BASE_VHOST_CONFIG_FILE 9

        if [ "$BASE_VHOST_CONFIG_FILE" == "" ] || [ ! -r "$BASE_VHOST_CONFIG_FILE" ]; then
            Aborting "transient error determining input config file template"
        else
            Base_Vhost_Echo "[OK] using template $BASE_VHOST_CONFIG_FILE"
        fi

        BASE_VHOST_SERVER_ALIASES=()

        BASE_VHOST_SERVER_ALIASES+=("www.${BASE_VHOST_SERVER_NAME}")
        if [ $DOMAIN_NAME_FLAG -eq 1 ] && [ "${BASE_VHOST_DOMAIN_NAME}" != "" ]; then
            if [[ ! "${BASE_VHOST_SERVER_NAME}" =~ (${BASE_VHOST_DOMAIN_NAME}$) ]]; then
                BASE_VHOST_SERVER_ALIASES+=("www.${BASE_VHOST_SERVER_NAME}.${BASE_VHOST_DOMAIN_NAME}")
            fi
        fi

        # this is a special condition; don't consult the do database if the input template has specific 2.4 based mod_authz Requires
        BASE_VHOST_NO_DO_ALIASES=$(cat "$BASE_VHOST_CONFIG_FILE" | egrep -ie 'NO_DO_ALIASES')

        for BASE_VHOST_SERVER_ALIAS in ${BASE_VHOST_SERVER_ALIASES[@]}; do

            for SERVER_ALIAS_RECORD in $SERVER_ALIAS_RECORDS; do
                if [ "$SERVER_ALIAS_RECORD" == "prod" ]; then continue; fi
                BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}.${BASE_VHOST_SERVER_ALIAS}")
                BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}.${BASE_VHOST_SERVER_NAME}")
                BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}-${BASE_VHOST_SERVER_ALIAS}")
                BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}-${BASE_VHOST_SERVER_NAME}")
                if [ $DOMAIN_NAME_FLAG -eq 1 ] && [ "${BASE_VHOST_DOMAIN_NAME}" != "" ]; then

                    if [[ ! "${BASE_VHOST_SERVER_NAME}" =~ (${BASE_VHOST_DOMAIN_NAME}$) ]]; then
                        if [ "${BASE_VHOST_DOMAIN_NAME}" != "${BASE_VHOST_SERVER_ALIAS}" ]; then
                            Debug_Variable BASE_VHOST_DOMAIN_NAME 3 "alias = ${BASE_VHOST_SERVER_ALIAS}"
                            BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}.${BASE_VHOST_SERVER_ALIAS}.${BASE_VHOST_DOMAIN_NAME}")
                            BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}-${BASE_VHOST_SERVER_ALIAS}.${BASE_VHOST_DOMAIN_NAME}")
                        fi

                        if [ "${BASE_VHOST_DOMAIN_NAME}" != "${BASE_VHOST_SERVER_NAME}" ] && [ "${BASE_VHOST_SERVER_NAME}" != "${BASE_VHOST_SERVER_ALIAS}" ]; then
                            Debug_Variable BASE_VHOST_DOMAIN_NAME 3 "name = ${BASE_VHOST_SERVER_NAME}"
                            BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}.${BASE_VHOST_SERVER_NAME}.${BASE_VHOST_DOMAIN_NAME}")
                            BASE_VHOST_SERVER_ALIASES+=("${SERVER_ALIAS_RECORD}-${BASE_VHOST_SERVER_NAME}.${BASE_VHOST_DOMAIN_NAME}")
                        fi
                    fi
                fi
            done

        done

        BASE_VHOST_SERVER_ALIASES_UNIQUE=$(echo "${BASE_VHOST_SERVER_ALIASES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        BASE_VHOST_SERVER_ALIASES=(${BASE_VHOST_SERVER_ALIASES_UNIQUE[@]})

        # make sure configs generated with this script have a consistent header line
        BASE_VHOST_CONFIG_FILE_MD5==$(md5sum "$BASE_VHOST_CONFIG_FILE" | awk '{print $1}')
        echo "# $BASE_VHOST_CONFIG_FILE md5sum $BASE_VHOST_CONFIG_FILE_MD5" > "$BASE_VHOST_HTTPD_CONF_D"

        sed "$BASE_VHOST_CONFIG_FILE" \
            -e "s|##ACCOUNT##|$BASE_VHOST_ACCOUNT|g" \
            -e "s|##CONFIG##|$CONFIG|g" \
            -e "s|##CONFIG_FILE##|$BASE_VHOST_CONFIG_FILE|g" \
            -e "s|##CONFIG_FILE_MD5##|$BASE_VHOST_CONFIG_FILE_MD5|g" \
            -e "s|##CERTIFICATE_FILE##|$BASE_VHOST_CERTIFICATE_FILE|g" \
            -e "s|##CERTIFICATE_CHAINFILE##|$BASE_VHOST_CERTIFICATE_CHAINFILE|g" \
            -e "s|##CERTIFICATE_KEYFILE##|$BASE_VHOST_CERTIFICATE_KEYFILE|g" \
            -e "s|##DOCUMENT_ROOT##|$BASE_VHOST_DOCUMENT_ROOT|g" \
            -e "s|##PREFIX##|$BASE_VHOST_PREFIX|g" \
            -e "s|##SERVER_IP##|$BASE_VHOST_SERVER_IP|g" \
            -e "s|##SERVER_NAME##|$BASE_VHOST_SERVER_NAME|g" \
            -e "s|##VHOSTS_CUSTOM_80##|$BASE_VHOST_VHOSTS_CUSTOM_80|g" \
            -e "s|##VHOSTS_CUSTOM_443##|$BASE_VHOST_VHOSTS_CUSTOM_443|g" \
            | sed \
            -e 's|[ \t]*$||g' \
            -e 's|^[ \t]*$||g' \
            >> "$BASE_VHOST_HTTPD_CONF_D"

        if [ $? -ne 0 ]; then
            Aborting "sed failed; $BASE_VHOST_HTTPD_CONF_D is probably broken" 1
        fi

        if [ "${BASE_VHOST_VHOSTS_CUSTOM_FILES}" != "" ]; then
            for BASE_VHOST_VHOSTS_CUSTOM_FILE in "${BASE_VHOST_VHOSTS_CUSTOM_FILES[@]}"; do
                echo "# WARNING! DO NOT EDIT THIS FILE  It was automatically generated by $0" > "${BASE_VHOST_VHOSTS_CUSTOM_FILE//custom/automatic}"
                sed "${BASE_VHOST_VHOSTS_CUSTOM_FILE}" \
                    -e "s|##ACCOUNT##|$BASE_VHOST_ACCOUNT|g" \
                    -e "s|##CONFIG##|$CONFIG|g" \
                    -e "s|##CONFIG_FILE##|$BASE_VHOST_CONFIG_FILE|g" \
                    -e "s|##CONFIG_FILE_MD5##|$BASE_VHOST_CONFIG_FILE_MD5|g" \
                    -e "s|##CERTIFICATE_FILE##|$BASE_VHOST_CERTIFICATE_FILE|g" \
                    -e "s|##CERTIFICATE_CHAINFILE##|$BASE_VHOST_CERTIFICATE_CHAINFILE|g" \
                    -e "s|##CERTIFICATE_KEYFILE##|$BASE_VHOST_CERTIFICATE_KEYFILE|g" \
                    -e "s|##DOCUMENT_ROOT##|$BASE_VHOST_DOCUMENT_ROOT|g" \
                    -e "s|##PREFIX##|$BASE_VHOST_PREFIX|g" \
                    -e "s|##SERVER_IP##|$BASE_VHOST_SERVER_IP|g" \
                    -e "s|##SERVER_NAME##|$BASE_VHOST_SERVER_NAME|g" \
                    -e "s|##VHOSTS_CUSTOM_80##|$BASE_VHOST_VHOSTS_CUSTOM_80|g" \
                    -e "s|##VHOSTS_CUSTOM_443##|$BASE_VHOST_VHOSTS_CUSTOM_443|g" \
                    | sed \
                    -e 's|[ \t]*$||g' \
                    -e 's|^[ \t]*$||g' \
                    >> "${BASE_VHOST_VHOSTS_CUSTOM_FILE//custom/automatic}"

                if [ $? -ne 0 ]; then
                    Aborting "sed failed; ${BASE_VHOST_VHOSTS_CUSTOM_FILE//custom/automatic} is probably broken" 1
                fi

                Base_Vhost_Echo "[OK] updated ${BASE_VHOST_VHOSTS_CUSTOM_FILE//custom/automatic}"
            done
        fi

        echo "# WARNING! DO NOT EDIT THIS FILE  It was automatically generated by $0" > "${BASE_VHOST_HTTPD_CONF_D}.aliases.automatic"
        if [ -f "${BASE_VHOST_HTTPD_CONF_D}.aliases.custom" ]; then
            echo "include ${BASE_VHOST_HTTPD_CONF_D}.aliases.custom" >> "${BASE_VHOST_HTTPD_CONF_D}.aliases.automatic"
        fi

        for BASE_VHOST_SERVER_ALIAS in ${BASE_VHOST_SERVER_ALIASES[@]}; do
            Debug_Variable BASE_VHOST_SERVER_ALIAS 10
            echo "ServerAlias $BASE_VHOST_SERVER_ALIAS" >> "${BASE_VHOST_HTTPD_CONF_D}.aliases.automatic"
        done

        if [ -f "${BASE_VHOST_HTTPD_CONF_D}.aliases.automatic" ]; then

            sed -i "$BASE_VHOST_HTTPD_CONF_D" \
                -e "s|##SERVER_ALIASES##|include ${BASE_VHOST_HTTPD_CONF_D}.aliases.automatic|g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        fi

        if [ $? -ne 0 ]; then
            Aborting "sed failed; $BASE_VHOST_HTTPD_CONF_D is probably broken" 3
        else
            RCS_FLAG=1
        fi

        Base_Vhost_Echo "[OK] created httpd.conf.d.aliases.automatic"

        if [ -f "${BASE_VHOST_HTTPD_CONF_D}.acl.custom" ]; then

            Base_Vhost_Echo "[OK] embedded httpd.conf.d.acl.custom"
            sed -i "$BASE_VHOST_HTTPD_CONF_D" \
                -e "s|##ACCESS_CONTROL_LIST##|include ${BASE_VHOST_HTTPD_CONF_D}.acl.custom|g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        else

            sed -i "$BASE_VHOST_HTTPD_CONF_D" \
                -e "s|##ACCESS_CONTROL_LIST##||g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        fi

        if [ $? -ne 0 ]; then
            Aborting "sed failed; $BASE_VHOST_HTTPD_CONF_D is probably broken" 3
        else
            RCS_FLAG=1
        fi

        Base_Vhost_Echo "[OK] created httpd.conf.d ($(basename "$BASE_VHOST_CONFIG_FILE"))"

    fi

    if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
        Base_Vhost_Echo "[OK] $BASE_VHOST_HTTPD_CONF_D"
    else
        Base_Vhost_Echo "[ERROR] missing httpd.conf.d"
        if [ $UPDATE_FLAG -eq 1 ]; then
            Base_Vhost_Echo "[UPDATE] !!! create httpd.conf.d !!! [not done yet]"
        else
            Base_Vhost_Reset_Globals
            continue
        fi
    fi

    # check DocumentRoot statements
    if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then

        while read BASE_VHOST_HTTPD_CONF_D_DOCUMENT_ROOT; do
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_DOCUMENT_ROOT 10
            if [ "$BASE_VHOST_HTTPD_CONF_D_DOCUMENT_ROOT" == "$BASE_VHOST_DOCUMENT_ROOT" ]; then
                Debug "[OK] found DocumentRoot '$BASE_VHOST_HTTPD_CONF_D_DOCUMENT_ROOT'" 1
            else
                Base_Vhost_Echo "[WARNING] incorrect DocumentRoot '$BASE_VHOST_HTTPD_CONF_D_DOCUMENT_ROOT'"
                break;
            fi
        done <<< "$(grep DocumentRoot "$BASE_VHOST_HTTPD_CONF_D" | egrep -ve '^#' | awk -F"#" '{print $1}' | awk -F DocumentRoot '{print $NF}' | sed -e '/"/s///g' -e '/^[ \t]*/s///g')"
    fi

    # check CustomLog statements
    if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
        BASE_VHOST_PREFIX_ACCOUNT_LOG="/var/log/httpd/${BASE_VHOST_ACCOUNT}"
        Debug_Variable BASE_VHOST_PREFIX_ACCOUNT_LOG 10

        BASE_VHOST_PREFIX_CUSTOM_LOG="/var/log/httpd/${BASE_VHOST_PREFIX}.access"
        Debug_Variable BASE_VHOST_PREFIX_CUSTOM_LOG 10

        while read BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_ENTRY; do
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_ENTRY 10

            BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT=$(echo "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_ENTRY" | awk '{print $2}')
            if [ "$BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT" == "" ]; then
                BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT="combined"
            fi
            Debug_Variable BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT 10

            BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG=$(echo "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_ENTRY" | awk '{print $1}')
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG 10

            if [ "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG" == "" ]; then continue; fi

            BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_443=$(cat "$BASE_VHOST_HTTPD_CONF_D" | egrep -e "\<VirtualHost|CustomLog" | grep -B1 "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG" | head -1 | awk -FVirtualHost '{print $NF}' | grep 443)
            if [ "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_443" == "" ]; then
                # assume port 80
                BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT="80"
            else
                # definitely port 443
                BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT="443"
            fi
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT 10

            if [ "$BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT" == "combined" ]; then
                BASE_VHOST_CUSTOM_LOG="${BASE_VHOST_PREFIX_CUSTOM_LOG}.${BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT}.log"
            else
                BASE_VHOST_CUSTOM_LOG="${BASE_VHOST_PREFIX_ACCOUNT_LOG}.${BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT}.log"
            fi
            Debug_Variable BASE_VHOST_CUSTOM_LOG 10

            BASE_VHOST_PREFIX_CUSTOM_LOG_MATCH=$(echo "$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG" | egrep -e "^${BASE_VHOST_CUSTOM_LOG}\ |${BASE_VHOST_CUSTOM_LOG}$")

            if [ "$BASE_VHOST_PREFIX_CUSTOM_LOG_MATCH" != "" ]; then
                Debug "[OK] found CustomLog ($BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT $BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT)" 1
            else
                Base_Vhost_Echo "[WARNING] incorrect CustomLog '$BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG' ($BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT $BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT)"
                if [ $ETC_FLAG -eq 1 ]; then
                    Base_Vhost_Echo "[UPDATE] correct CustomLog '$BASE_VHOST_CUSTOM_LOG' ($BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG_PORT $BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT)"
                    sed -i "s#${BASE_VHOST_HTTPD_CONF_D_CUSTOM_LOG}#${BASE_VHOST_CUSTOM_LOG}#g" "${BASE_VHOST_HTTPD_CONF_D}"
                    RCS_FLAG=1
                fi
            fi

            BASE_VHOST_PREFIX_CUSTOM_LOG_FORMAT=""
        done <<< "$(grep CustomLog "$BASE_VHOST_HTTPD_CONF_D" | egrep -ve '^#' | awk -F"#" '{print $1}' | awk -FCustomLog '{print $NF}')"
    fi

    # check ErrorLog statements
    if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
        BASE_VHOST_PREFIX_ERROR_LOG="/var/log/httpd/${BASE_VHOST_PREFIX}.error"
        Debug_Variable BASE_VHOST_PREFIX_ERROR_LOG 10

        while read BASE_VHOST_HTTPD_CONF_D_ERROR_LOG; do
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_ERROR_LOG 10

            BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_443=$(cat "$BASE_VHOST_HTTPD_CONF_D" | egrep -e "\<VirtualHost|ErrorLog" | grep -B1 "$BASE_VHOST_HTTPD_CONF_D_ERROR_LOG" | head -1 | awk -FVirtualHost '{print $NF}' | grep 443)
            if [ "$BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_443" == "" ]; then
                # assume port 80
                BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT="80"
            else
                # definitely port 443
                BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT="443"
            fi
            Debug_Variable BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT 10

            BASE_VHOST_ERROR_LOG="${BASE_VHOST_PREFIX_ERROR_LOG}.${BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT}.log"
            Debug_Variable BASE_VHOST_ERROR_LOG 10

            BASE_VHOST_PREFIX_ERROR_LOG_MATCH=$(echo "$BASE_VHOST_HTTPD_CONF_D_ERROR_LOG" | grep ^"${BASE_VHOST_ERROR_LOG}")

            if [ "$BASE_VHOST_PREFIX_ERROR_LOG_MATCH" != "" ]; then
                Debug "[OK] found ErrorLog ($BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT)" 1
            else
                Base_Vhost_Echo "[WARNING] incorrect ErrorLog '$BASE_VHOST_HTTPD_CONF_D_ERROR_LOG' ($BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT)"
                if [ $ETC_FLAG -eq 1 ]; then
                    Base_Vhost_Echo "[UPDATE] correct ErrorLog '$BASE_VHOST_ERROR_LOG' ($BASE_VHOST_HTTPD_CONF_D_ERROR_LOG_PORT)"
                    sed -i "s#${BASE_VHOST_HTTPD_CONF_D_ERROR_LOG}#${BASE_VHOST_ERROR_LOG}#g" "${BASE_VHOST_HTTPD_CONF_D}"
                    RCS_FLAG=1
                fi
            fi
        done <<< "$(grep ErrorLog "$BASE_VHOST_HTTPD_CONF_D" | egrep -ve '^#' | awk -F"#" '{print $1}' | awk -F ErrorLog '{print $NF}' | sed -e "/\"/s///g" -e '/^[ \t]*/s///g')"
    fi

    if [ $ETC_FLAG -eq 1 ]; then
        BASE_VHOST_ETC_HTTPD_CONF_D_DIRS+=" /etc/httpd/conf.d"
    fi
    if [ "$MACHINE_FLAG" -eq 1 ] && [ "$MACHINE" != "" ]; then
        if [ ! -d "${BASE_DIR}/machine/${MACHINE}/etc/httpd/conf.d" ]; then
            mkdir -p "${BASE_DIR}/machine/${MACHINE}/etc/httpd/conf.d"
            if [ $? -ne 0 ]; then
                Aborting "${BASE_DIR}/machine/${MACHINE}/etc/httpd/conf.d mkdir failed" 2
            fi
        fi
        BASE_VHOST_ETC_HTTPD_CONF_D_DIRS+=" ${BASE_DIR}/machine/${MACHINE}/etc/httpd/conf.d"
    fi
    BASE_VHOST_ETC_HTTPD_CONF_D_DIRS=$(List_Unique "$BASE_VHOST_ETC_HTTPD_CONF_D_DIRS")
    Debug_Variable BASE_VHOST_ETC_HTTPD_CONF_D_DIRS 20

    for BASE_VHOST_ETC_HTTPD_CONF_D_DIR in $BASE_VHOST_ETC_HTTPD_CONF_D_DIRS; do

        # validate the links in BASE_VHOST_ETC_HTTPD_CONF_D_DIR are correct (& fix them if necessary)

        if [ -d "$BASE_VHOST_ETC_HTTPD_CONF_D_DIR" ]; then
            if [ "${BASE_VHOST_PREFIX}" == "" ]; then
                Aborting "BASE_VHOST_PREFIX is null"
            fi

            Debug_Variable BASE_VHOST_ETC_HTTPD_CONF_D_DIR 10

            BASE_VHOST_ETC_HTTPD_CONF_D="${BASE_VHOST_ETC_HTTPD_CONF_D_DIR}/${BASE_VHOST_PREFIX}.conf"
            Debug_Variable BASE_VHOST_ETC_HTTPD_CONF_D 10

            if [ -f "$BASE_VHOST_ETC_HTTPD_CONF_D" ] || [ -h "$BASE_VHOST_ETC_HTTPD_CONF_D" ]; then
                BASE_VHOST_ETC_HTTPD_CONF_D_LINK="$(find "$BASE_VHOST_ETC_HTTPD_CONF_D" -type l -printf '%l')"

                if [ "$BASE_VHOST_ETC_HTTPD_CONF_D_LINK" == "$BASE_VHOST_HTTPD_CONF_D" ]; then
                    Debug "[OK] found link $BASE_VHOST_ETC_HTTPD_CONF_D" 1
                    continue
                else
                    Base_Vhost_Echo "[ERROR] incorrect link $BASE_VHOST_ETC_HTTPD_CONF_D ($BASE_VHOST_ETC_HTTPD_CONF_D_LINK)"
                    if [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
                        if [ $ETC_FLAG -eq 1 ] || [ $MACHINE_FLAG -eq 1 ]; then
                            Base_Vhost_Echo "[UPDATE] remove link $BASE_VHOST_ETC_HTTPD_CONF_D"
                            rm -f "$BASE_VHOST_ETC_HTTPD_CONF_D"
                            if [ $? -ne 0 ]; then
                                Base_Vhost_Echo "[ERROR] failed to remove $BASE_VHOST_ETC_HTTPD_CONF_D"
                                continue
                            else
                                RCS_FLAG=1
                            fi
                        fi
                    fi
                fi
                BASE_VHOST_ETC_HTTPD_CONF_D_LINK=""
            fi

            if [ ! -f "$BASE_VHOST_ETC_HTTPD_CONF_D" ] && [ ! -h "$BASE_VHOST_ETC_HTTPD_CONF_D" ]; then
                Base_Vhost_Echo "[WARNING] missing link $BASE_VHOST_ETC_HTTPD_CONF_D"
                if [ $ETC_FLAG -eq 1 ] || [ $MACHINE_FLAG -eq 1 ]; then
                    if [ ! -f "$BASE_VHOST_ETC_HTTPD_CONF_D" ] && [ ! -h "$BASE_VHOST_ETC_HTTPD_CONF_D" ] && [ -s "$BASE_VHOST_HTTPD_CONF_D" ]; then
                        Base_Vhost_Echo "[UPDATE] link $BASE_VHOST_ETC_HTTPD_CONF_D"
                        ln -s "$BASE_VHOST_HTTPD_CONF_D" "$BASE_VHOST_ETC_HTTPD_CONF_D"
                        if [ $? -ne 0 ]; then
                            Base_Vhost_Echo "[ERROR] failed to link $BASE_VHOST_ETC_HTTPD_CONF_D"
                            Base_Vhost_Reset_Globals
                            continue
                        else
                            RCS_FLAG=1
                        fi
                    fi
                fi
            fi
        fi

    done

    Base_Vhost_Reset_Globals
done

if [ $ETC_FLAG -eq 1 ]; then
    LINK_CHECK_DIRS=""
    LINK_CHECK_DIRS+="/etc/httpd/conf.d/"
    if [ "$MACHINE" != "" ]; then
        LINK_CHECK_DIRS+=" ${BASE_DIR}/machine/${MACHINE}/etc/httpd/conf.d/"
    fi
    Debug_Variable LINK_CHECK_DIRS 20

    for LINK_CHECK_DIR in $LINK_CHECK_DIRS; do
        if [ ! -d "$LINK_CHECK_DIR" ]; then continue; fi
        BROKEN_LINKS=`find $LINK_CHECK_DIR -type l -xtype l`
        if [ "$BROKEN_LINKS" != "" ]; then
            Warning "Removing broken symbolic links in $LINK_CHECK_DIR ..."

            for BROKEN_LINK in $BROKEN_LINKS; do
                if [ -f "${BROKEN_LNK}" ] || [ -h "${BROKEN_LINK}" ]; then
                    echo "Removing broken symlink link $BROKEN_LINK ..."
                    svn rm "${BROKEN_LINK}" &> /dev/null
                    if [ -f "${BROKEN_LNK}" ] || [ -h "${BROKEN_LINK}" ]; then
                        rm -f "$BROKEN_LINK"
                    fi
                    RCS_FLAG=1
                fi
            done
        fi
    done
fi

if [ $CONFIG_FLAG -eq 1 ]; then
    echo
    echo -n "Checking default httpd configuration for syntax errors ... "
    apachectl configtest &> /dev/null
    if [ $? -eq 0 ]; then
        echo "[OK]"
    else
        echo "[ERROR]"
        echo
        apachectl configtest
    fi
fi

if [ $RCS_FLAG -eq 1 ]; then
    echo
    echo "NOTE: changes were made; however 'svn add' & 'svn commit' must be manually executed"
fi

if [ $PERMS_FLAG -eq 1 ] && [ $PERMS_SET -eq 1 ]; then
    echo
    echo "NOTE: svn properties were set; however 'svn commit' must be manually executed"
fi

#set | grep ^BASE | grep -v BASE_VHOST
echo
Stop 0
