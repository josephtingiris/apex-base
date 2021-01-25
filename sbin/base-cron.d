#!/bin/bash

# This script will ... find cron.d run-parts directories & add/check them into svn, set perms, etc

# 20140920, jtingiris
# 20150621, jtingiris, revised (new naming convention & organization)

# For coding conventions, organization, standards, & references, see: /base/README

# begin base.bash.include

if [ "$DEBUG" == "" ]; then
    DEBUG=0
fi

PATH_SHELL=$PATH
PATH=/bin:/usr/bin:/sbin:/usr/sbin

INCLUDE_FILE="base.bash"
INCLUDE_FOUND=0
INCLUDE_PATHS=("$(pwd)" "$(dirname $0)" /base /usr/local)
for INCLUDE_PATH in ${INCLUDE_PATHS[@]}; do
    if [ $INCLUDE_FOUND -eq 1 ]; then break; fi
    while [ ! -z "$INCLUDE_PATH" ]; do
        if [ "$INCLUDE_PATH" == "." ]; then INCLUDE_PATH=$(pwd -L .); fi
        if [ "$INCLUDE_PATH" == "/" ]; then break; fi
        if [ -r "$INCLUDE_PATH/include/$INCLUDE_FILE" ] && [ ! -d "$INCLUDE_PATH/include/$INCLUDE_FILE" ]; then
            INCLUDE_FOUND=1
            source "$INCLUDE_PATH/include/$INCLUDE_FILE"
            Debug "sourced $INCLUDE_PATH/include/$INCLUDE_FILE" 100
            break
        else
            INCLUDE_PATH=$(dirname "$INCLUDE_PATH")
        fi
    done
done
if [ $INCLUDE_FOUND -ne 1 ]; then echo "$INCLUDE_FILE file not found"; exit 1; fi
if [ "$BASE_INCLUDE" == "" ]; then echo "$INCLUDE_FILE file invalid"; exit 1; fi
unset INCLUDE_COUNTER INCLUDE_PATH INCLUDE_FILE

# end base.bash.include

# GLOBAL_VARIABLES

# explicit declarations

declare -x DEFAULT_DATE=`date +%Y%m%d`

declare -i ACCOUNT_FLAG=0
declare -i COMMIT_FLAG=0
declare -i EDIT_FLAG=0
declare -i PERMS_FLAG=0
declare -i TEST_FLAG=0
declare -i YES_FLAG=0

declare -i RC=0

declare -x VERSION="0.1";

# Function_Names

function Usage() {

    Debug_Function $@

    local note="$1"

    # begin function logic

    echo
    echo "usage: $0 <options>"
    echo
    echo "options:"
    echo

    # these are handled in base.bash; useful to know though
    echo "  -D | --debug [level]           = print debug messages (less than) [level]"
    echo "  -H | --help                    = print this message"
    echo "  -V | --version                 = print version"
    echo

    # these must be handled in this script; please keep usage messages accurate
    echo "  --edit                         = before parsing, edit cron.d files (with vim)"
    echo
    echo "  --commit                       = svn commit cron.d files"
    echo "  --perms                        = svn set & run perms"
    echo
    echo "  --test                         = don't actually do anything"
    echo
    echo "  --yes                          = answer 'yes' to all questions (automate)"
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
    -a | --account | -account)
        ACCOUNT_FLAG=1
        ACCOUNT="$2"
        if [ "$ACCOUNT" != "" ] && [ ${ACCOUNT:0:1} == "-" ]; then
            ACCOUNT=""
        fi
        if [ "$ACCOUNT" != "" ]; then
            declare ACCOUNT=$2
            Debug_Variable ACCOUNT 4 "$1 flag was set"
            shift
        fi
        ;;
    -c | --commit | -commit | commit)
        COMMIT_FLAG=1
        ;;
    -e | --edit | -edit | edit)
        EDIT_FLAG=1
        ;;
    -p | --perms | -perms | perms)
        PERMS_FLAG=1
        ;;
    -t | --test | -test | test)
        TEST_FLAG=1
        ;;
    -y | --yes | -yes | yes)
        YES_FLAG=1
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

# Main Logic

if [ $ARGUMENTS_TOTAL -eq 0 ]; then Usage; fi

Start

if [ ! -d "$BASE_DIR" ] || [ "$BASE_DIR" == "" ]; then
    Aborting "base directory not found"
fi

if [ ! -d "$BASE_DIR_ACCOUNT" ] || [ "$BASE_DIR_ACCOUNT" == "" ]; then
    Aborting "account directory not found"
fi

if [ $TEST_FLAG -eq 0 ] && [ $YES_FLAG -eq 0 ]; then
    Question "this makes changes to cron.d files; continue"
    if [ "$QUESTION_FLAG" -ne 1 ]; then
        Aborting "nothing done"
    fi
fi

ETC_DIRS=()

if [ $ACCOUNT_FLAG -eq 1 ]; then

    if [ "$ACCOUNT" == "" ] || [ "$ACCOUNT" == "base" ]; then
        if [ -d "${BASE_DIR}/etc" ]; then
            ETC_DIRS+=("${BASE_DIR}/etc")
        fi

        if [ "$ACCOUNT" == "" ]; then
            for BASE_DIR_ACCOUNT_ETC in $(ls -1 "${BASE_DIR_ACCOUNT}"); do
                if [ -d "${BASE_DIR_ACCOUNT}/${BASE_DIR_ACCOUNT_ETC}/etc" ]; then
                    ETC_DIRS+=("${BASE_DIR_ACCOUNT}/${BASE_DIR_ACCOUNT_ETC}/etc")
                fi
            done
        fi
    else
        if [ -d "${BASE_DIR}/account/${ACCOUNT}/etc" ]; then
            ETC_DIRS+=("${BASE_DIR}/account/${ACCOUNT}/etc")
        fi
    fi

else

    ETC_DIRS+="/etc"

fi

if [ "$ETC_DIRS" == "" ]; then
    Aborting "could not find any matching cron.d directories"
fi

Dependency "svn"

let ETC_COUNTER=0
for ETC_DIR in ${ETC_DIRS[@]}; do

    Debug_Variable ETC_DIR 3 $HERE

    CRON_D_DIR="${ETC_DIR}/cron.d"

    if [ ! -d "${CRON_D_DIR}" ]; then
        # nothing to do
        continue;
    fi

    let ETC_COUNTER=$ETC_COUNTER+1

    cd "${ETC_DIR}"

    echo
    echo "+ [$ETC_COUNTER][$(pwd)] processing"

    ETC_SVN_INFO=$(svn info 2> /dev/null |  grep ^URL:)

    if [ "$ETC_SVN_INFO" != "" ]; then

        echo "+ [$ETC_COUNTER][$(pwd)] svn info"

        if [ $DEBUG -gt 0 ]; then
            echo
            echo "$ETC_SVN_INFO"
            echo
        fi

        echo "+ [$ETC_COUNTER][$(pwd)] svn up"

        if [ $TEST_FLAG -eq 0 ]; then
            svn up &> /dev/null
            if [ $? -ne 0 ]; then
                Aborting "svn up $ETC_DIR failed"
            fi
        fi

    fi

    cd "${CRON_D_DIR}"

    echo "+ [$ETC_COUNTER][$(pwd)] processing"

    CRON_D_FILES=$(find . -maxdepth 1 -type f -name "*.cron.d" -o -type l -name "*.cron.d")
    for CRON_D_FILE_NAME in $CRON_D_FILES; do

        CRON_D_FILE="${CRON_D_DIR}/$(basename "$CRON_D_FILE_NAME")"

        if [ ! -f "$CRON_D_FILE" ]; then
            Aborting "undetermined problem"
        fi

        if [ $EDIT_FLAG -eq 1 ]; then

            echo "+ [$ETC_COUNTER][$(pwd)] editing $CRON_D_FILE"

            vim "$CRON_D_FILE"
        fi

        echo "+ [$ETC_COUNTER][$(pwd)] parsing $CRON_D_FILE"

        RUN_PARTS_DIRS=() # reset

        while read -r RUN_PARTS; do
            #echo "RUN_PARTS=$RUN_PARTS"

            RUN_PARTS_DIR=$(echo "(" &> /dev/null; echo "$RUN_PARTS" | awk -Frun-parts '{print $NF}' | awk -F\) '{print $1}')
            RUN_PARTS_DIR=$(List_Unique "$RUN_PARTS_DIR")

            Debug_Variable RUN_PARTS_DIR 10

            CRON_USER=$(echo "$RUN_PARTS" | awk '{print $6}')

            if [ "$CRON_USER" == "" ]; then
                Warning "cron user is null in $CRON_D_FILE"
                continue
            fi

            CRON_USER_PASSWD=$(grep ^${CRON_USER}: /etc/passwd 2> /dev/null)
            if [ "$CRON_USER_PASSWD" == "" ]; then
                Warning "$CRON_USER is not in /etc/passwd"
                continue
            fi

            CRON_LOG="$(echo "$RUN_PARTS" | awk '{print $NF}')"

            if [ "$CRON_LOG" == "" ]; then
                Warning "$CRON_LOG is null in $CRON_D_FILE"
                continue
            fi

            CRON_LOG_DIR=$(dirname "$CRON_LOG")

            Debug_Variable CRON_LOG_DIR 10

            if [ "$RUN_PARTS_DIR" == "$CRON_LOG_DIR" ]; then
                Aborting "run-parts and cron log directories are identical ($RUN_PARTS_DIR)"
            fi

            # always do this (before processing RUN_PARTS_DIR)
            IO_DIRS=("${CRON_LOG_DIR}" "${RUN_PARTS_DIR}")
            for IO_DIR in ${IO_DIRS[@]}; do

                # no need to do the same directory twice
                case "${RUN_PARTS_DIRS[@]}" in
                *"$IO_DIR"*)
                    continue
                    ;;
                esac

                echo "+ [$ETC_COUNTER][$IO_DIR] checking"

                if [ ! -d "$IO_DIR" ]; then

                    echo "+ [$ETC_COUNTER][$(pwd)] mkdir $IO_DIR"

                    if [ $TEST_FLAG -eq 0 ]; then
                        mkdir -p "$IO_DIR"
                    fi

                fi

                if [ ! -d "$IO_DIR" ]; then
                    Aborting "'$IO_DIR' directory not found"
                fi

                if [ -d "$IO_DIR" ]; then

                    while read USER_FILE; do
                        if [ "$USER_FILE" == "" ]; then
                            continue
                        fi

                        echo "+ [$ETC_COUNTER][$(pwd)] fixing; chown $USER_FILE to $CRON_USER"

                        if [ $TEST_FLAG -eq 0 ]; then
                            chown "$CRON_USER" "$USER_FILE"
                        fi
                    done <<< "$(find "$IO_DIR" ! -user "$CRON_USER")"

                fi

                RUN_PARTS_DIRS+=("$IO_DIR")

                continue

            done

            if [ $COMMIT_FLAG -eq 0 ] && [ $PERMS_FLAG -eq 0 ]; then
                continue # no need to proceed
            fi

            cd "$RUN_PARTS_DIR"

            if [ $COMMIT_FLAG -eq 1 ] || [ $PERMS_FLAG -eq 1 ]; then

                if [ "$ETC_SVN_INFO" == "" ]; then

                    RUN_PARTS_SVN_INFO=$(svn info 2> /dev/null |  grep ^URL:)

                    if [ "$RUN_PARTS_SVN_INFO" != "" ]; then

                        echo "+ [$ETC_COUNTER][$(pwd)] svn info"

                        if [ $DEBUG -gt 0 ]; then
                            echo
                            echo "$RUN_PARTS_SVN_INFO"
                            echo
                        fi
                    fi

                else

                    RUN_PARTS_SVN_INFO="$ETC_SVN_INFO"

                fi

                if [ "$RUN_PARTS_SVN_INFO" != "" ]; then

                    if [ $TEST_FLAG -eq 0 ]; then

                        echo "+ [$ETC_COUNTER][$(pwd)] svn add"

                        svn add --force .

                        echo "+ [$ETC_COUNTER][$(pwd)] svn propset"

                        while read RUN_PARTS_FILE; do
                            if [ -d "$RUN_PARTS_FILE" ]; then
                                svn propset owner $CRON_USER "$RUN_PARTS_FILE" &> /dev/null
                            fi
                            svn propset mode 0750 "$RUN_PARTS_FILE" &> /dev/null
                            svn propset svn:executable on "$RUN_PARTS_FILE" &> /dev/null
                        done <<< "$(find "${RUN_PARTS_DIR}")"
                    fi

                    if [ "$ETC_SVN_INFO" == "" ]; then # do this only if the parent directory svn info is empty (slower)

                        if [ $PERMS_FLAG -eq 1 ]; then

                            echo "+ [$ETC_COUNTER][$(pwd)] svn perms"

                            if [ $TEST_FLAG -eq 0 ]; then
                                svn perms &> /dev/null
                            fi
                        fi

                        if [ $COMMIT_FLAG -eq 1 ]; then

                            echo "+ [$ETC_COUNTER][$(pwd)] svn commit"

                            if [ $TEST_FLAG -eq 0 ]; then
                                echo
                                svncommit cron -m "$0 commit"
                                echo
                                svn up &> /dev/null
                            fi
                        fi

                    fi

                fi
            fi


        done <<< "$(grep run-parts "$CRON_D_FILE" | grep -v ^\#)"
        RUN_PARTS_SVN_INFO=""

        cd "$CRON_D_DIR"

        if [ "$ETC_SVN_INFO" != "" ]; then

            if [ $PERMS_FLAG -eq 1 ]; then

                echo "+ [$ETC_COUNTER][$(pwd)] svn perms"

                if [ $TEST_FLAG -eq 0 ]; then
                    svn perms &> /dev/null
                fi
            fi

            if [ $COMMIT_FLAG -eq 1 ]; then

                echo "+ [$ETC_COUNTER][$(pwd)] svn commit"

                if [ $TEST_FLAG -eq 0 ]; then
                    echo
                    svncommit cron -m "$0 commit"
                    echo
                    svn up &> /dev/null
                fi
            fi

        fi

    done

    cd "${ETC_DIR}"

    if [ "$ETC_SVN_INFO" != "" ]; then

        echo "+ [$ETC_COUNTER][$(pwd)] svn up"

        if [ $TEST_FLAG -eq 0 ]; then
            svn up &> /dev/null
        fi

        echo "+ [$ETC_COUNTER][$(pwd)] svn stat"

        if [ $TEST_FLAG -eq 0 ]; then
            #echo
            svn stat
            echo
        fi

    fi

done

cd "$HERE"

Stop $RC
