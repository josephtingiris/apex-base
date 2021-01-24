#!/bin/bash

# This is a bash include file that contains some useful, reusable global variables & functions.

# Copyright (C) 2013-2020 Joseph Tingiris (joseph.tingiris@gmail.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

#
# 20191113, joseph.tingiris@gmail.com, maintenance review (still using daily); moved primary repo from local svn to github
# 20170704, joseph.tingiris@gmail.com, began renaming functions & stuff
# 20130228, joseph.tingiris@gmail.com
#

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/usr/sbin:/bin:/usr/bin:${PATH}"

# disable all globbing
set -f

# Global_Variables (that do not require dependencies)

# these primarily exist as markers, to know that this script has been sourced
declare -x Apex_Source="${BASH_SOURCE}"

declare -x APEX_INCLUDE="${Apex_Source}" # deprecated; do not use anymore
declare -x Apex_Include="${Apex_Source}" # deprecated; do not use anymore
declare -x APEX_SOURCE="${Apex_Source}" # deprecated; do not use anymore

if [ "${Apex_Dir}" == "" ]; then
    Apex_Dirs="/apex /base"

    for Apex_Dir in ${Apex_Dirs}; do
        if [[ "${PWD}" =~ ^${Apex_Dir} ]]; then
            break
        else
            unset -v Apex_Dir
        fi
    done

    if [ ${#Apex_Dir} -eq 0 ]; then
        for Apex_Dir in ${Apex_Dirs}; do
            if [ -d "${Apex_Dir}" ]; then
                break
            else
                unset -v Apex_Dir
            fi
        done
    fi

    if [ ${#Apex_Dir} -eq 0 ]; then
        Apex_Dir="/tmp"
    fi
fi

# much of this script depends on Apex_Dir, so make sure it's there & valid
if [ ! -d "${Apex_Dir}" ]; then
    echo
    echo "${Apex_Dir} directory not found"
    echo
    exit 1
else
    if [ ! -r "${Apex_Dir}" ]; then
        echo
        echo "${Apex_Dir} directory not readable"
        echo
        exit 1
    fi
fi

# Apex named globals

export Apex_Bash=$(readlink -e $BASH_SOURCE)
export Apex_Bash_Dir=$(dirname "$Apex_Bash")

Apex_Debug_Bash_Dir=${Apex_Bash_Dir}
Apex_Debug_Bash_Depth=0
while [ "${Apex_Debug_Bash_Dir}" != "/" ]; do
    ((Apex_Debug_Bash_Depth++))

    Apex_Debug_Bash="${Apex_Debug_Bash_Dir}/debug-bash/Debug.bash"

    if [ -r "${Apex_Debug_Bash}" ]; then
        break
    fi

    Apex_Debug_Bash_Dir=${Apex_Debug_Bash_Dir%/*}
    if [ ${Apex_Debug_Bash_Depth} -ge 10 ]; then
        break
    fi
done

if [ -r "${Apex_Debug_Bash}" ]; then
    source "${Apex_Debug_Bash}"
fi

if [ "$Apex_0" == "" ]; then Apex_0=$0; fi
if [ "$Apex_0" == "-bash" ]; then Apex_0=$Apex_Bash; fi

if [ "$Apex_Arguments" == "" ]; then Apex_Arguments=$@; fi

declare -i Apex_Arguments_Count=$#

if [ "$Apex_Backup_Dir" == "" ]; then Apex_Backup_Dir="/backup"; fi # put this outside ${Apex_Dir}

if [ "$Apex_Datacenters" == "" ]; then Apex_Datacenters="atl dal lon man"; fi

if [ "$Apex_Environments" == "" ]; then Apex_Environments="dev qa staging production"; fi

if [ "$Apex_Hostname" == "" ]; then Apex_Hostname=$(hostname -s); fi

if [ "$Apex_Pid" == "" ]; then Apex_Pid=$BASHPID; fi # BASHPID

if [ "$Apex_User" == "" ]; then Apex_User="$USER"; fi # USER
if [ "$Apex_User" == "" ]; then Apex_User="nobody"; fi # USER

if [ "$Apex_Logname" == "" ]; then Apex_Logname="$LOGNAME"; fi # LOGNAME
if [ "$Apex_Logname" == "" ]; then Apex_Logname="$(logname 2> /dev/null)"; fi # LOGNAME
if [ "$Apex_Logname" == "" ]; then Apex_Logname="$Apex_User"; fi # LOGNAME
if [ "$Apex_Logname" == "" ]; then Apex_Logname="nobody"; fi # LOGNAME

if [ "$Apex_Usage" == "" ]; then Apex_Usage=(); fi

# non-Apex named globals

if [ "$Debug" == "" ]; then Debug=0; fi

if [ "$Debug_Flag" == "" ]; then declare -i Debug_Flag=1; fi

if [ "$Here" == "" ]; then Here=$(readlink -f ${PWD}); fi

if [ "$Logfile" == "" ]; then Logfile="/tmp/${Apex_Base_Name}.log"; fi

if [ "$Lockfile" == "" ]; then Lockfile="/tmp/${Apex_Base_Name}.lock"; fi

if [ "$Lockfile_Flag" == "" ]; then Lockfile_Flag=1; fi

if [ "$Machine_Dir" == "" ]; then Machine_Dir="${Apex_Dir}/machine"; fi

if [ "$Machine_Backup_Dir" == "" ]; then Machine_Backup_Dir="$Apex_Backup_Dir/machine/$Apex_Hostname"; fi

if [ "$Option" == "" ]; then declare -i Option=0; fi

if [ "$Pwd" == "" ]; then Pwd=$(pwd); fi

if [ "$Question_Flag" == "" ]; then declare -i Question_Flag=1; fi

if [ "$Ssh" == "" ]; then Ssh=$(type -P ssh 2> /dev/null); fi

if [ "$Step" == "" ]; then declare -i Step=0; fi

if [ "$Time_Start" == "" ]; then Time_Start=$(date +%s%N); fi

if [ "$Verbose_Flag" == "" ]; then declare -i Verbose_Flag=1; fi

if [ "$Version" == "" ]; then Version="0"; fi

if [ "$Whom" == "" ]; then Whom=$(who -m); fi

if [ "$Who" == "" ]; then Who="${Whom%% *}"; fi

if [ "$Who" == "" ]; then Who=$Apex_User; fi

if [ "$Who" == "" ]; then Who=$Apex_Logname; fi

if [ "$Who" == "" ]; then Who=UNKNOWN; fi

if [ "$Who_Ip" == "" ]; then Who_Ip="${Whom#*(}"; Who_Ip="${Who_Ip%)*}"; fi

if [ "$Who_Ip" == "" ] && [ "$SSH_CLIENT" != "" ]; then Who_Ip=${SSH_CLIENT%% *}; fi

if [ "$Who_Ip" == "" ]; then Who_Ip="0.0.0.0"; fi

# bash environment (overrides)

export PATH="${Apex_Dir}/sbin:${Apex_Dir}/bin:${PATH}"

if [ "$TERM" == "" ]; then export TERM="vt100"; fi

# Functions

function _prototypeFunction() {
    debugFunction $@ # call debugFunction when the function finished

    # begin function logic

    echo "Apex World!"

    # end function logic

    debugFunction $@ # call debugFunction again to know when the function finished
}

function aborting() {
    debugFunction $@

    # begin function logic

    if [ "$2" == "" ]; then
        local -i return_code="$2"
    else
        local -i return_code=9
    fi
    local aborting_message="aborting, $1 (${return_code}) ..."

    echo
    echo "${aborting_message}"
    echo

    systemLog "${aborting_message}"

    apexFinish ${return_code}

    # end function logic

    debugFunction $@
}

function apex() {
    debugFunction $@

    # begin function logic

    echo 1

    # end function logic

    debugFunction $@
}

function apexStart() {
    debugFunction $@

    # begin function logic

    debug "$Apex_0 started" 101

    debugColors

    debugValue "BASH_ARGC" 102
    debugValue "BASH_LINENO" 102
    debugValue "BASH_SOURCE" 102
    debugValue "PATH" 102
    debugValue "TERM" 102

    #debugValue "Apex_Arguments" 101
    Apex_Sets=$(set | grep ^Apex | grep = | awk -F= '{print $1}'| sort -u)
    for Apex_Set in $Apex_Sets; do
        debugValue ${Apex_Set} 25
    done
    debugValue "Debug" 101
    debugValue "Here" 101
    debugValue "Lockfile" 101
    Machine_Sets=$(set | grep ^Machine | grep = | awk -F= '{print $1}'| sort -u)
    for Machine_Set in $Machine_Sets; do
        debugValue ${Machine_Set} 25
    done
    debugValue "Ssh" 101
    debugValue "Tmp_File" 101
    debugValue "Who" 101
    debugValue "Who_Ip" 101

    # end function logic

    debugFunction $@
}

# deprecated apexStart aliases

function begin() {
    apexStart $@
}

# clean up & end a program
function apexFinish() {
    debugFunction $@

    # begin function logic

    local -i return_code="$1"

    Step=0

    if [ -f "$Tmp_File" ]; then
        rm "$Tmp_File"
    fi

    cd "$Here"

    debug "$Apex_0 finished in $Seconds seconds" 101

    # end function logic

    debugFunction $@

    exit ${return_code}
}

# deprecated apexFinish aliases

function end() {
    apexFinish $@
}

function backupFiles() {
    debugFunction $@

    # begin function logic

    if [ "$1" == "" ]; then
        return
    else
        local backup_files="$1"
    fi

    if [ "$2" == "" ]; then
        local backup_files_directory=$Apex_Backup_Dir
    else
        local backup_files_directory="$2"
    fi

    if [ "${backup_files_directory}" == "" ]; then
        aborting "backup_files_directory is null"
    fi

    if [ ! -d "${backup_files_directory}" ]; then
        mkdir -p "${backup_files_directory}"
        if [ $? ne 0 ]; then
            aborting "failed to create backup file directory ${backup_files_directory}" 4
        fi
    fi

    debugValue backup_files_directory 13

    local backup_file
    for backup_file in ${backup_files}; do
        debugValue backup_file 12
        if [ -d "${backup_file}" ]; then continue; fi
        if [ -f "${backup_file}" ]; then
            local backup_file_basename=$(basename "${backup_file}")
            local backup_file_dirname=$(dirname "${backup_file}")
            debugValue backup_file_basename 13
            debugValue backup_file_dirname 13

            backup_file_last=$(find ${backup_files_directory} -name "${backup_file_basename}\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.[0-9]*" | sort -n | tail -1)
            if [ "${backup_file_last}" != "" ] && [ -f "${backup_file_last}" ] && [ -f "${backup_file}" ]; then
                debugValue backup_file_last 3
                diff "${backup_file}" "${backup_file_last}" &> /dev/null
                if [ $? -eq 0 ]; then
                    debug "validated backup ${backup_file_last}" 1
                    continue
                fi
            fi

            local -i backup_file_counter=0
            while [ -f "${backup_file_name}" ] || [ "${backup_file_name}" == "" ]; do
                let backup_file_counter=${backup_file_counter}+1
                backup_file_name="${backup_files_directory}/${backup_file_basename}.${Apex_Uniq}.${backup_file_counter}"
            done
            debugValue backup_file_name 13

            cp "${backup_file}" "${backup_file_name}"
            if [ $? -ne 0 ]; then
                aborting "failed to backup $backup_file"
            else
                echo "created backup $backup_file_name"
            fi
        else
            warning "$backup_file is missing"
        fi
    done

    # end function logic

    debugFunction $@
}

# deprecated; use debug-bash
if ! type -t debug &> /dev/null; then
    function debug() {

        # begin function logic

        local debug_message="$1"
        local -i debug_level="$2"
        local debug_function_name="$3"
        local -i debug_output=0

        if [ "${Debug}" == "" ]; then
            Debug=0
        else
            # recast Debug as an integer, e.g. in case a string was given
            local -i debug_integer=${Debug}
            Debug=${debug_integer}
        fi

        if [ ${Debug} -ge ${debug_level} ]; then
            local -i debug_output=1
        fi

        if [ ${debug_level} -eq 0 ]; then
            # any debug with a level of zero; message will be displayed
            local -i debug_output=1
        fi

        if [ ${debug_output} -eq 1 ]; then

            # display the appropriate message
            local debug_identifier="debug [${debug_level}]"
            printf "%s : %s\n" "${debug_identifier}" "${debug_message}"

        fi

        unset debugFunction_Name

        # end function logic

    }
fi

# deprecated; use debug-bash
if ! type -t debugColors &> /dev/null; then
    function debugColors() {

        # begin function logic

        if [ $Debug -lt 1000 ]; then return; fi # this function provides little value to an end user

        printf "# this debugColors is deprecated; use debug-bash\n"

        # end function logic

    }
fi

# deprecated; use debug-bash
if ! type -t debugFunction &> /dev/null; then
    function debugFunction() {

        # begin function logic

        return

        # end function logic

    }
fi

# deprecated; use debug-bash
if ! type -t debugSeparator &> /dev/null; then
    function debugSeparator() {

        # begin function logic

        local separator_character="$1"
        local -i debug_level="$2"
        local -i separator_length="$3"

        if [ "${separator_character}" == "" ]; then separator_character="="; fi
        if [ ${separator_length} -eq 0 ]; then separator_length=80; fi

        local separator=""
        while [ ${separator_length} -gt 0 ]; do
            local separator+=${separator_character}
            local -i separator_length=$((separator_length-1))
        done

        debug ${separator} ${debug_level}

        # end function logic

    }
fi

# deprecated; use debug-bash
if ! type -t debugValue &> /dev/null; then
    function debugValue() {

        # begin function logic

        local variable_name=$1
        local -i debug_level="$2"
        local variable_comment="$3"

        local variable_value=${!variable_name}
        if [ "$variable_value" == "" ]; then variable_value="Null"; fi

        # manual padding; call debug() to display it
        local -i variable_pad=25 # the character position to pad to
        local -i variable_padded=0
        local -i variable_length=${#variable_name}
        local -i variable_position=${variable_pad}-${variable_length}

        while [ ${variable_padded} -le ${variable_position} ]; do
            local variable_name+=" "
            local -i variable_padded=$((variable_padded+1))
        done

        if [ "${Debug}" == "" ]; then Debug=0; fi
        if [ "${variable_comment}" != "" ]; then variable_value+=" (${variable_comment})"; fi

        debug "${variable_name} = ${variable_value}" ${debug_level}

        # end function logic

    }
fi

# dependency checks to make sure a dependent file exists in the environment PATH and aborts if it doesn't
function dependency() {

    local dependency dependencies=($@)

    for dependency in ${dependencies[@]}; do
        if [ "${dependency}" == "" ]; then
            continue
        fi

        if ! type -t ${dependency} &> /dev/null; then
            aborting "dependency '${dependency}' alias, file, and/or function not found" 2
        fi
    done
    unset dependency dependencies

}

# List functions should not produce any output other than the list (i.e. do not use debug(), debugFunction, etc)
function listUnique() {

    # begin function logic

    local input_list="$1"
    if [ "$input_list" == "" ]; then return; fi

    # set the list separating character
    local sep="$2"
    if [ "${sep}" == "" ]; then sep=":space:"; fi
    if [ "${sep}" == " " ]; then sep=":space:"; fi

    echo "${input_list}" | awk -v RS='[['${sep}']]+' '!a[$0]++{printf "%s%s", $0, RT}' | sed -e '/^[ |\t]*/s///g' -e '/[ |\t]*$/s///g' -e '/[ |\t]*[ \t]/s// /g'

    # end function logic

}

function optionArguments() {
    debugFunction $@

    # begin function logic

    local input_argument=""

    if [ "$1" == "" ]; then
        local input_arguments=($Apex_Arguments)
    else
        local input_arguments=($@)
    fi

    # set the usage prior to the first usage() call

    if [ ${#Apex_Usage} -gt 0 ]; then
        Apex_Usage+=("")
    fi

    Apex_Usage+=("-D | --debug [level]           = display debug messages (less than) [level]")
    Apex_Usage+=("-H | --help                    = display this message")
    Apex_Usage+=("-V | --version                 = display version")
    Apex_Usage+=("")

    # because the arguments get 'shifted' each time, make sure to set unknown options in a global (for re-processing)

    Option_Arguments=()

    # for each command line argument, evaluate them case by case ...

    local -i input_arguments_index=0
    local -i input_arguments_shift=0
    for input_argument in ${input_arguments[@]}; do

        if [ ${input_arguments_shift} -eq 1 ]; then
            ((input_arguments_index++))
            input_arguments_shift=0
            continue
        fi

        input_arguments_next="${input_arguments[${input_arguments_index}+1]}"

        case "${input_argument}" in

            -D | --D | -debug | --debug)
                Debug_Flag=0
                if [ "${input_arguments_next}" == "" ] || [ "${input_arguments_next:0:1}" == "-" ]; then
                    Debug=0
                else
                    if [ "${input_arguments_next}" == "restart" ] || [ "${input_arguments_next}" == "start" ] || [ "${input_arguments_next}" == "status" ] || [ "${input_arguments_next}" == "stop" ]; then
                        Debug=0
                    else
                        Debug=${input_arguments_next}
                    fi
                    input_arguments_shift=1
                fi
                debugValue Debug 2 "${input_argument} flag was set"
                ;;

            -H | --H | -help | --help | -usage | --usage)
                debugValue Help 2 "${input_argument} flag was set"
                usage
                ;;

            -V | --V | -version | --version)
                debugValue Version 2 "${input_argument} flag was set"
                echo "$Apex_0 (apex) version $Version"
                exit
                ;;

            *)
                if [ "${input_argument}" != "" ]; then
                    # set only what's unknown in the global
                    Option_Arguments+=("$input_argument")
                fi
                ;;
        esac

        ((input_arguments_index++))

    done

    #echo "Option_Arguments = ${Option_Arguments[@]}"

    # end function logic

    debugFunction $@
}

function question() {
    debugFunction $@

    # begin function logic

    local question_message=""
    if [ "$Machine_Name" != "" ]; then local question_message+="$Machine_Name : "; fi
    local question_message+="$1"

    if [ "$Yes_Flag" == "" ]; then Yes_Flag=1; fi

    Question_Flag=1

    if [ $Yes_Flag -eq 0 ]; then
        Question_Flag=0
    else
        declare -l Y_N_Q=""
        echo
        echo -n "$question_message [y/n/q] ? "
        read Y_N_Q
        echo
        if [ "${Y_N_Q:0:1}" == "q" ]; then apexFinish 1; fi
        if [ "${Y_N_Q:0:1}" == "y" ]; then
            Question_Flag=0
        fi
        Y_N_Q=""
    fi

    # end function logic

    debugFunction $@
}

function requireInclude() {
    debugFunction $@

    # begin function logic

    include_file="$1"

    if [ "$include_file" == "" ]; then
        aborting "null include file not found" 2
    fi

    include_found=0
    include_paths="$(dirname $Apex_0) $(pwd)"
    for include_path in $include_paths; do
        if [ $include_found -eq 1 ]; then break; fi
        while [ ! -z "$include_path" ]; do
            if [ "$include_path" == "." ]; then include_path=$(pwd -L .); fi
            if [ "$include_path" == "/" ]; then break; fi
            if [ -r "$include_path/include/$include_file" ] && [ ! -d "$include_path/include/$include_file" ]; then
                include_found=1
                source "$include_path/include/$include_file"
                debug "sourced $include_path/include/$include_file" 5
                unset include_path include_file
                break
            else
                include_path=$(dirname "$include_path")
            fi
        done
    done
    if [ $include_found -ne 1 ]; then aborting "$include_file include file not found" 1; fi

    # end function logic

    debugFunction $@
}

function step() {
    debugFunction $@

    # begin function logic

    let Step=$Step+1

    local machine_name_minimum_width="            "
    local step_minimum_width="   "

    local time_stamp=$(date)
    if [ $Step -gt 0 ]; then
        printf "%s : %s%s : step %s%s : %s\n" "$time_stamp" "${Machine_Name}" "${machine_name_minimum_width:${#Machine_Name}}" "$Step" "${step_minimum_width:${#Step}}" "$1"
    else
        printf "%s : %s%s : %s\n" "$time_stamp" "${Machine_Name}" "${machine_name_minimum_width:${#Machine_Name}}" "$1"
    fi

    # end function logic

    debugFunction $@
}

function stepVerbose() {
    debugFunction $@

    # begin function logic

    if [ $Verbose_Flag -eq 0 ]; then
        step "$@"
    fi

    # end function logic

    debugFunction $@
}

function systemLog() {
    debugFunction $@

    # begin function logic

    local log_message=$@
    if [ ${#log_message} -gt 0 ]; then
        # default maximum permitted message size for logger is 1KiB; RFC 3164
        log_message=${log_message:0:1024}
        #log_message=${log_message//"/\\"}
        #log_message=${log_message//'/\\'}
        # TODO fewer pipes
        echo "${log_message}" | sed -e '/"/s///g' -e "/'/s//\\\'/g" | xargs logger -t "$(basename $Apex_0) : $Who : $Who_Ip : $Apex_Logname : $Pwd " --
    fi

    # end function logic

    debugFunction $@
}

# upgrade "this (file)" "to/from (list of directories)"; automatically chooses the 'newest' file
function upgrade() {
    debugFunction $@

    # begin function logic

    if [ $# -ne 2 ]; then
        debug "incorrect number of arguments, doing nothing" 102
        return
    fi

    local upgrade_file="$1"
    if [ "$upgrade_file" == "" ]; then local upgrade_file="$Apex_0"; fi

    if [ "$upgrade_file" == "" ]; then
        debug "null upgrade_file, doing nothing" 1
        return
    fi

    if [ ! -f "$upgrade_file" ]; then
        debug "$upgrade_file is not a file, doing nothing" 102
        return
    fi

    local upgrade_basename=$(basename $upgrade_file)
    local upgrade_dirname=$(dirname $upgrade_file)
    debugValue "upgrade_basename" 101
    debugValue "upgrade_dirname" 101

    local upgrade_list="$2"

    if [ "$upgrade_list" == "" ]; then
        debug "null upgrade_list, doing nothing" 1
        return
    fi

    local upgrade_list+=" $upgrade_dirname"
    local upgrade_list=$(listUnique "$upgrade_list")
    debugValue "upgrade_list" 101

    local upgrade_dirs=""
    for upgrade_check in $upgrade_list; do
        debugValue "upgrade_check" 11
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
    local upgrade_dirs=$(listUnique "$upgrade_dirs")
    debugValue "upgrade_dirs" 101

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
    debugValue "upgrade_epochs" 101

    local upgrade_epochs_sort_n=($(for each in ${upgrade_epochs[@]}; do echo $each; done | sort -n))
    #echo "upgrade_epochs       =${upgrade_epochs[@]}"
    #echo "upgrade_epochs_sort_n=${upgrade_epochs_sort_n[@]}"

    local upgrade_epoch=${upgrade_epochs_sort_n[@]-1}
    #local upgrade_epoch=${upgrade_epochs_sort_n%%* }
    debugValue "upgrade_epoch" 101

    local upgrade_epoch_file=${upgrade_epoch##*,} # strip off the epoch time to get a reusable, named variable to work with
    debugValue "upgrade_epoch_file" 101

    local -i upgraded=0
    local upgrade_dir=""
    for upgrade_dir in $upgrade_dirs; do
        if [ "$upgrade_dir/$upgrade_basename" == "$upgrade_epoch_file" ]; then continue; fi # don't copy the newest file over itself

        if [ ! -d "$upgrade_dir" ]; then
            mkdir -p "$upgrade_dir"
            local return_code=$?
            if [ $return_code -ne 0 ]; then aborting "failed to mkdir -p '$upgrade_dir'" 1; fi
            continue
        fi

        diff -q "$upgrade_epoch_file" "$upgrade_dir/$upgrade_basename" &> /dev/null
        local return_code=$?
        if [ $return_code -ne 0 ]; then
            # they differ, so upgrade (copy) to the latest 'epoch' file ...
            cp -p "$upgrade_epoch_file" "$upgrade_dir/$upgrade_basename"
            local return_code=$?
            if [ $return_code -ne 0 ]; then aborting "failed to copy '$upgrade_epoch_file' to '$upgrade_dir/$upgrade_basename'" 1; fi
            echo "upgraded $upgrade_dir/$upgrade_basename ..."
            local -i upgraded=1
        else
            debug "no need to upgrade $upgrade_dir/$upgrade_basename" 11
            local -i upgraded=0
        fi

    done

    # end function logic

    debugFunction $@

    if [ $upgraded -eq 1 ]; then
        if [ -x "$Apex_0" ]; then
            echo "restarting $Apex_0 $Apex_Arguments ..."
            sync
            sleep 1
            exec $Apex_0 $Apex_Arguments
            apexFinish 1
        fi
    fi
}

function usage() {
    debugFunction $@

    # begin function logic

    shopt -s extglob

    local apex_option apex_option_help apex_required apex_usage apex_usage_arguments

    if [ ${#Apex_Required} -gt 0 ]; then
        for apex_required in ${Apex_Required[@]}; do
            apex_usage_arguments+="<${apex_required}> "
        done
    fi

    if [ ${#Apex_Usage} -gt 0 ]; then
        apex_usage_arguments+="[options] "
    fi

    apex_usage_arguments=${apex_usage_arguments##+([[:space:]])} # remove leading whitespaces
    apex_usage_arguments=${apex_usage_arguments%%+([[:space:]])} # remove trailing whitespaces

    printf "usage: ${Apex_0} ${apex_usage_arguments}\n\n"

    if [ ${#Apex_Usage} -gt 0 ]; then
        printf "options:\n\n"
        for apex_usage in "${Apex_Usage[@]}"; do
            apex_option=${apex_usage%%=*}
            apex_option=${apex_option##+([[:space:]])}
            apex_option=${apex_option%%+([[:space:]])}

            apex_option_help=${apex_usage#*=}
            apex_option_help=${apex_option_help##+([[:space:]])}
            apex_option_help=${apex_option_help%%+([[:space:]])}

            if [ "${apex_option}" == "" ] && [ "${apex_option_help}" == "" ]; then
                printf "\n"
                continue
            fi

            if [ "${apex_option}" == "${apex_option_help}" ]; then
                apex_option=""
            fi
            printf "%-50s %s\n" "${apex_option}" "${apex_option_help}"
        done
        printf "\n"
    fi

    if [ "$1" != "" ]; then
        printf "Note: ${@}\n\n"
    fi

    shopt -u extglob

    # end function logic

    debugFunction $@

    apexFinish 1
}

function warning() {
    debugFunction $@

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

    debugFunction $@
}

# Main Logic

Apex_Dependencies=()

# validate these dependencies exist
Apex_Dependencies+=(awk)
Apex_Dependencies+=(basename)
Apex_Dependencies+=(cut)
Apex_Dependencies+=(date)
Apex_Dependencies+=(dirname)
Apex_Dependencies+=(egrep)
Apex_Dependencies+=(find)
Apex_Dependencies+=(grep)
Apex_Dependencies+=(head)
Apex_Dependencies+=(host)
Apex_Dependencies+=(hostname)
Apex_Dependencies+=(ip)
Apex_Dependencies+=(printf)
Apex_Dependencies+=(pwd)
Apex_Dependencies+=(readlink)
Apex_Dependencies+=(sed)
Apex_Dependencies+=(sort)
Apex_Dependencies+=(stat)
Apex_Dependencies+=(tail)
Apex_Dependencies+=(uniq)
Apex_Dependencies+=(uuidgen)
Apex_Dependencies+=(who)

dependency ${Apex_Dependencies[@]}

# Global_Variables (that require dependencies)

if [ "$Apex_Account_Dir" == "" ]; then
    Apex_Account_Dir="${Apex_Dir}/account"
    if [ ! -d "$Apex_Account_Dir" ]; then
        mkdir -p "$Apex_Account_Dir"
        if [ $? -ne 0 ]; then
            aborting "failed to create account directory $Apex_Account_Dir" 4
        fi
    fi
fi

if [ "$Apex_Account" == "" ]; then
    Apex_Account=$(realpath $(pwd) | awk -F\/ '{print $4}')
    if [ ! -d "$Apex_Account_Dir/$Apex_Account" ]; then
        Apex_Account=""
    fi
fi

if [ "$Apex_Base_Name" == "" ]; then Apex_Base_Name="$(basename $Apex_0)"; fi

Apex_0_Dir=$(dirname $Apex_0)
Apex_Dir_0=$Apex_0_Dir # deprecated; do not use anymore

if [ "$Apex_Company" == "" ]; then
    if [ -r "/etc/company_name" ]; then
        Apex_Company=$(cat "/etc/company_name")
    else
        if [ -r "${Apex_Dir}/etc/company_name" ]; then
            Apex_Company=$(cat "${Apex_Dir}/etc/company_name")
        else
            Apex_Company="Private Use"
        fi
    fi
fi

if [ "$Apex_Domain_Name" == "" ]; then
    if [ -r "/etc/domain_name" ]; then
        Apex_Domain_Name=$(cat "/etc/domain_name")
    else
        if [ -r "${Apex_Dir}/etc/domain_name" ]; then
            Apex_Domain_Name=$(cat "${Apex_Dir}/etc/domain_name")
        else
            Apex_Domain_Name=localdomain
        fi
    fi
fi

if [ "$Apex_Uniq" == "" ]; then Apex_Uniq=$(date +%Y%m%d)-$(uuidgen); fi

if [ "$Tmp_File" == "" ]; then Tmp_File="/tmp/$(basename $Apex_0).${Apex_Uniq}.tmp"; fi

if [ "$Machine_Class" == "" ]; then Machine_Class=$(echo $Apex_Hostname | awk -F\. '{print $1}' | sed -e '/[0-9]/s///g'); fi

if [ "$Machine_Environment" == "" ]; then declare -l Machine_Environment=$(echo $Apex_Hostname | awk -F\. '{print $1}' | awk -F- '{print $2}'); fi
if [ "${Machine_Environment:0:2}" == "qa" ]; then Machine_Environment="qa"; fi
if [ "${Machine_Environment:0:3}" == "dev" ]; then Machine_Environment="dev"; fi
if [ "$Machine_Environment" != "dev" ] && [ "$Machine_Environment" != "qa" ]; then Machine_Environment="prod"; fi

if [ "$Machine_Name" == "" ]; then Machine_Name=$Apex_Hostname; fi

#
# Gobal_Variable (validation)
#

# validate Apex_Hostname
if [ "$Apex_Hostname" == "" ]; then
    aborting "Apex_Hostname is empty"
fi

# validate Datacenter
declare -i Datacenter_Valid=0

declare -l Machine_Datacenter=$(echo $Machine_Name | awk -F\. '{print $1}' | awk -F- '{print $1}' | cut -c -3)
for Apex_Datacenter in $Apex_Datacenters; do
    if [ "$Machine_Datacenter" == "$Apex_Datacenter" ]; then
        Datacenter_Valid=1
        break;
    fi
done
if [ $Datacenter_Valid -eq 0 ]; then
    Apex_Datacenter=""
    Machine_Datacenter=""
fi

if [ -f /etc/machine ]; then
    for Apex_Environment_Override in $Apex_Environments; do
        if [ "$Machine_Environment_Override" != "" ]; then continue; fi
        Machine_Environment_Override=$(grep "^${Apex_Environment_Override}$" /etc/machine)
    done
    if [ "$Machine_Environment_Override" != "" ]; then
        Machine_Environment="$Machine_Environment_Override"
    fi
    unset Apex_Environment_Override
    unset Machine_Environment_Override
fi

# validate Environment
declare -i Environment_Valid=0

for Apex_Environment in $Apex_Environments; do
    if [ "$Machine_Environment" == "$Apex_Environment" ]; then
        Environment_Valid=1
        break;
    fi
done
if [ $Environment_Valid -eq 0 ]; then
    Apex_Environment=""
    Machine_Environment=""
fi

if [ $Datacenter_Valid -eq 1 ] && [ $Environment_Valid -eq 0 ]; then
    Apex_Environment="prod"
    Machine_Environment="prod"
fi

if [ "$Apex_Environment" == "" ]; then
    Apex_Environment="dev"
fi

# upgrade "this (file)" "to/from (list of directories)"
# upgrade $BASH_SOURCE "/usr/local/include ${Apex_Dir}/include"

# re-enable globbing
set +f

apexStart
