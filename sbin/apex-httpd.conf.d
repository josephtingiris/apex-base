#!/bin/bash

# This script will ... check & conform directories to base httpd.conf.d sematics

# This script will provide data values based on a directory name.

# Copyright (C) 2019 Joseph Tingiris (joseph.tingiris@gmail.com)

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

# begin Apex.bash.include

if [ ${#Debug} -gt 0 ]; then
    Debug=${Debug}
else
    if [ ${#DEBUG} -gt 0 ]; then
        Debug=${DEBUG}
    else
        Debug=0
    fi
fi

if [ ${#Apex_Bash_Source} -eq 0 ]; then
    Apex_Bashes=()
    Apex_Bashes+=(Apex.bash)
    Apex_Bashes+=(Base.bash)

    Apex_Bash_Dirs=()
    Apex_Bash_Dirs+=(/apex)
    Apex_Bash_Dirs+=(/base)
    Apex_Bash_Dirs+=(/usr)
    Apex_Bash_Dirs+=(${BASH_SOURCE%/*})
    Apex_Bash_Dirs+=(~)

    for Apex_Bash_Dir in ${Apex_Bash_Dirs[@]}; do
        while [ ${#Apex_Bash_Dir} -gt 0 ] && [ "${Apex_Bash_Dir}" != "/" ]; do # search backwards
            Apex_Bash_Source_Dirs=()
            Apex_Bash_Source_Dirs+=("${Apex_Bash_Dir}/include/apex-bash")
            Apex_Bash_Source_Dirs+=("${Apex_Bash_Dir}/include")
            Apex_Bash_Source_Dirs+=("${Apex_Bash_Dir}")
            for Apex_Bash in ${Apex_Bashes[@]}; do
                for Apex_Bash_Source_Dir in ${Apex_Bash_Source_Dirs[@]}; do
                    Apex_Bash_Source=${Apex_Bash_Source_Dir}/${Apex_Bash}

                    if [ -r "${Apex_Bash_Source}" ]; then
                        source "${Apex_Bash_Source}"
                        break
                    else
                        unset -v Apex_Bash_Source
                    fi
                done
                [ ${Apex_Bash_Source} ] && break
            done
            [ ${Apex_Bash_Source} ] && break
            Apex_Bash_Dir=${Apex_Bash_Dir%/*} # search backwards
        done
        [ ${Apex_Bash_Source} ] && break
    done
fi

if [ ${#Apex_Bash_Source} -eq 0 ] || [ ! -r "${Apex_Bash_Source}" ]; then
    echo "${Apex_Bash} file not readable"
    exit 1
fi

# end Apex.bash.include

# Global_Variables

Default_Vhost_Dirs=(certificate html include session)
Default_Vhost_Ignores=(bin default.content content classes etc include includes legacy lib machine sbin vendor)

Default_Vhost_Owner=apache
Default_Vhost_Group=apache
Default_Vhost_Mode=0770

# explicit declarations

declare -x DEFAULT_DATE=`date +%Y%m%d`

declare -i Return_Code=0

declare -x VERSION="0.1";

Perms_Set=1

# Function_Names

function vhostResetGlobals() {
    # make sure to reset these!
    Vhost=""
    Vhost_Account=""
    Vhost_Basename=""
    Vhost_Certificate_File=""
    Vhost_Certifificate_File_Candidate=""
    Vhost_Certificate_File_Candidates=()
    Vhost_Certificate_Chainfile=""
    Vhost_Certificate_Chainfile_Candidate=""
    Vhost_Certificate_Chainfile_Candidates=()
    Vhost_Certificate_Keyfile=""
    Vhost_Certificate_Keyfile_Candidate=""
    Vhost_Certificate_Keyfile_Candidates=()
    Vhost_Config_File=""
    Vhost_Config_File_Last=""
    Vhost_Config_File_MD5=""
    Vhost_Dirs=()
    Vhost_Ignore=""
    Vhost_Ignores=()
    Vhost_Custom_Log=""
    Vhost_Custom_Log_Match=""
    Vhost_Dir=""
    Vhost_Dirname=""
    Vhost_Document_Root=""
    Vhost_Domain_Name=""
    Vhost_Error_Log=""
    Vhost_Error_Log_Match=""
    Vhost_Etc_Httpd_Conf_D_Dirs=""
    Vhost_Group=""
    Vhost_Httpd_Conf_D=""
    Vhost_Httpd_Conf_D_Custom_Log_443=""
    Vhost_Httpd_Conf_D_Custom_Log_Port=""
    Vhost_Mode=""
    Vhost_Owner=""
    Vhost_Prefix=""
    Vhost_Prefix_Account_Log=""
    Vhost_Prefix_Custom_Log=""
    Vhost_Server_Alias=""
    Vhost_Server_Aliases=()
    Vhost_Server_Aliases_UNIQUE=()
    Vhost_Server_IP=""
    Vhost_Server_Name=""
    Vhost_Vhosts_Custom_80=""
    Vhost_Vhosts_Custom_443=""
    Vhost_Skip=""
    Vhost_Svn_URL=""
}

function vhostEcho() {
    local base_vhost_echo_message="$1"
    if [ "${base_vhost_echo_message}" == "" ]; then
        base_vhost_echo_message="NULL"
    fi
    if [ ${Search_Flag} -eq 1 ]; then
        echo "[${Vhost_Count}] [${Vhost_Account}] [${Vhost}] ... ${base_vhost_echo_message}"
    fi
}

# Validation Logic

dependency "apachectl sed svn tr"

# add usage help to the Apex_Usage array (before usage() is called for the first time [via optionArguments])

Apex_Usage+=("-c | --config [name] = update config from /*/etc/httpd.conf.d.[name]")
Apex_Usage+=("=note: a special keyword of 'last' exists for this option")
Apex_Usage+=("=if no [name] is given then 'last' is the default")
Apex_Usage+=("=using '--config last' will use the previous template httpd.conf.d was created with")
Apex_Usage+=("") # blank link; seperator
Apex_Usage+=("-d | --domain-name <name>  = update config using domain <name> instead of what's automatically determined")
Apex_Usage+=("=note: a special keyword of 'last' exists for this option")
Apex_Usage+=("") # blank link; seperator
Apex_Usage+=("-i | --ip <address> = use ip <address> for VirtualHost bindings (default='*')")
Apex_Usage+=("-l | --link = update symbolic links in /etc/httpd/conf.d")
Apex_Usage+=("-m | --machine <name> = update symbolic links in /base/machine/<name>/etc/httpd/conf.d")
Apex_Usage+=("-f | --force = force updates")
Apex_Usage+=("-p | --perms = update svn & file permissions for document root")
Apex_Usage+=("-r | --record [environment] = update ServerAlias records for the given [environments] (default='dev local qa')")
Apex_Usage+=( "=note: a special keyword of 'prod' exists for this option")
Apex_Usage+=( "=using '--record prod' will *NOT* produce the default dev, local, & qa ServerAliases")
Apex_Usage+=("") # blank link; seperator
Apex_Usage+=("-s | --search = search for --domain-name <name> in httpd.conf.d files")
Apex_Usage+=("-u | --update = update everything (except config)")
Apex_Usage+=("-x | --recursive = run recusively from $(pwd)")

# call the optionArguments function (to process common options, i.e. --debug, --help, --usage, --yes, etc)

optionArguments $@

# expand upon the optionArguments function (careful, same named switches will be processed twice)

# for each cli option (argument), evaluate them case by case, process them, and shift to the next

# 0=true, 1=false
declare -i Config_Flag=1
declare -i Domain_Name_Flag=1
declare -i Etc_Flag=1
declare -i Force_Flag=1
declare -i IP_FLAG=1
declare -i Link_Flag=1
declare -i Machine_Flag=1
declare -i Perms_Flag=1
declare -i Record_Flag=1
declare -i Recursive_Flag=1
declare -i Rcs_Flag=1
declare -i Search_Flag=1
declare -i Update_Flag=1

declare -i Option_Arguments_Index=0
declare -i Option_Arguments_Shift=0
for Option_Argument in ${Option_Arguments[@]}; do

    if [ ${Option_Arguments_Shift} -eq 1 ]; then
        ((Option_Arguments_Index++))
        Option_Arguments_Shift=0
        continue
    fi

    Option_Argument_Next="${Option_Arguments[${Option_Arguments_Index}+1]}"

    case "${Option_Argument}" in
        -c | --config | -config)
            # supports only one argument with a value
            if [ ${Config_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Config+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Config="$(listUnique "${Config}")"
            if [ "${Config}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Config_Flag=0
            debugValue Config_Flag 2 "${Option_Argument} flag was set [${Config}]"
            ;;

        -d | --domain | -domain | --domain-name | -domain-name)
            # supports only one argument with a value
            if [ ${Domain_Name_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Domain_Name+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Domain_Name="$(listUnique "${Domain_Name}")"
            if [ "${Domain_Name}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Domain_Name_Flag=0
            debugValue Domain_Name_Flag 2 "${Option_Argument} flag was set [${Domain_Name}]"
            ;;

        -i | --ip | -ip)
            # supports only one argument with a value
            if [ ${IP_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare IP+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            IP="$(listUnique "${IP}")"
            if [ "${IP}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            IP_Flag=0
            debugValue IP_Flag 2 "${Option_Argument} flag was set [${IP}]"
            ;;

        -l | --link | -link)
            # supports only one argument without a value
            if [ ${Link_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Link_Flag=0
            Etc_Flag=0
            debugValue Link_Flag 2 "${Option_Argument} flag was set"
            ;;

        -m | --machine | -machine)
            # supports only one argument with a value
            if [ ${Machine_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Machine+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Machine="$(listUnique "${Machine}")"
            if [ "${Machine}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Machine_Flag=0
            debugValue Machine_Flag 2 "${Option_Argument} flag was set [${Machine}]"
            ;;


        -f | --force | -force)
            # supports only one argument without a value
            if [ ${Force_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Force_Flag=0
            debugValue Force_Flag 2 "${Option_Argument} flag was set"
            ;;

        -p | --perms | -perms | --perm | -perm)
            # supports only one argument without a value
            if [ ${Perms_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Perms_Flag=0
            debugValue Perms_Flag 2 "${Option_Argument} flag was set"
            ;;

        -r | --record | -record)
            # supports only one argument with a value
            if [ ${Record_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Record+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Record="$(listUnique "${Record}")"
            if [ "${Record}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Record_Flag=0
            debugValue Record_Flag 2 "${Option_Argument} flag was set [${Record}]"
            ;;

        -s | --search | -search)
            # supports only one argument without a value
            if [ ${Search_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Search_Flag=0
            debugValue Search_Flag 2 "${Option_Argument} flag was set"
            ;;

        -e | --etc | -etc)
            # supports only one argument without a value
            if [ ${Etc_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Etc_Flag=0
            debugValue Etc_Flag 2 "${Option_Argument} flag was set"
            ;;

        -u | --update | -update)
            # supports only one argument without a value
            if [ ${Update_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Update_Flag=0
            debugValue Update_Flag 2 "${Option_Argument} flag was set"
            ;;

        -x | --recursive | -recursive)
            # supports only one argument without a value
            if [ ${Recursive_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            Recursive_Flag=0
            debugValue Recursive_Flag 2 "${Option_Argument} flag was set"
            ;;

        *)
            # unsupported arguments
            if [ "${Option_Argument}" != "" ]; then
                echo "unsupported argument '${Option_Argument}'"
                apexFinish 2
            fi
            ;;
    esac

    ((Option_Arguments_Index++))
done
unset Option_Argument_Next Option_Arguments_Index Option_Arguments_Shift

# e.g., if there are no arguments, echo a usage message and/or exit

if [ ${Apex_Arguments_Count} -eq 0 ]; then usage; fi
if [ ${Apex_Arguments_Count} -eq 1 ] && [ ${Debug_Flag} -ne 1 ]; then usage; fi
if [ ${Apex_Arguments_Count} -eq 2 ] && [ ${Debug_Flag} -ne 1 ] && [ "${Debug}" != "" ]; then usage; fi

# Main Logic

apexStart

# set all flags if -u is given
if [ ${Update_Flag} -eq 0 ]; then
    Etc_Flag=0
    Link_Flag=0
    Machine_Flag=0
    Perms_Flag=0
fi

if [ "${Record}" == "" ]; then
    Server_Alias_Records="dev local qa"
    Record=${Server_Alias_Records}
else
    Server_Alias_Records="${Record}"
fi

if [ ${Config_Flag} -eq 0 ]; then

    debugValue Apex_Environment 3
    debugValue Machine_Environment 3

    if [ "${Config}" == "" ]; then
        Config="last"
    fi

    Config_Files=("$(pwd)/httpd.conf.d.${Config}" "${Apex_Account_Dir}/${Apex_Account}/etc/httpd.conf.d.${Config}" "${Apex_Dir}/etc/httpd.conf.d.${Config}")


    for Config_File in ${Config_Files[@]}; do
        debugValue Config_File 24 "search"
        if [ -s "${Config_File}" ]; then
            break;
        else
            Config_File=""
        fi
    done
    debugValue Config_File 10

    if [ "${Config}" != "" ] && [ -r "${Config}" ] && [ "${Config_File}" == "" ]; then
        Config_File="${Config}"
    fi

    if [ "${Config}" == "dyanmic" ] || [ "${Config}" == "last" ]; then
        Config_File="dynamic"
        Config_File_MD5="md5sum"
    else
        if [ "${Config_File}" == "" ]; then
            aborting "Config_File is empty" 1
        fi
        if [ ! -r "${Config_File}" ]; then
            aborting "${Config_File} file not found" 1
        else
            Config_File_MD5=$(md5sum "${Config_File}" | awk '{print $1}')
        fi
    fi

    echo
    echo $(date)
    echo
    echo "Template ${Config_File} (${Config_File_MD5}) ... [OK]"
fi

if [ ${Recursive_Flag} -eq 0 ]; then
    Find_Depth=""
else
    # do NOT recurse
    Find_Depth="-maxdepth 1"
fi

debugValue Find_Depth 24

if [ ${Search_Flag} -eq 0 ]; then
    echo
    if [ "${Find_Depth}" == "" ]; then
        echo "Searching ${Here} for all potentially valid base document roots ... [OK]"
    else
        echo "Checking ${Here} for valid base document root ... [OK]"
    fi
fi

# base virtual host *should* have an html directory and an accompanying httpd.conf.d file; find either or
# create (and subsequently unique) an array of vhost directories; exclude nested html directories
Vhosts=()

while read Vhost; do
    Vhost=$(echo -n "${Vhost}" | sed -e '/\/$/s///g')
    debugValue Vhost 23 read
    Vhost_Basename=$(basename "${Vhost}")
    debugValue Vhost_Basename 31
    Vhost_Dirname=$(dirname "${Vhost}")
    debugValue Vhost_Dirname 31

    if [ "${Vhost_Basename}" == "httpd.conf.d" ]; then
        if [ -d "${Vhost_Dirname}" ]; then
            debugValue Vhost 30 dirname
            Vhosts+=("${Vhost_Dirname}")
        fi
    else
        if [ -d "${Vhost}" ]; then
            debugValue Vhost 30 dirname
            Vhosts+=("${Vhost}")
        fi
    fi

    vhostResetGlobals
done <<< "$(find ${Here}/ ${Find_Depth} -type f -name httpd.conf.d -o -type d -name html | awk -Fhtml '{print $1}')"

Vhosts_Unique=$(echo "${Vhosts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
Vhosts=(${Vhosts_Unique[@]})

if [ ${#Vhosts} -eq 0 ]; then
    Abort_Message="can't find"
    if [ ${Recursive_Flag} -eq 0 ]; then
        Abort_Message+=" any "
    else
        Abort_Message+=" a "
    fi
    Abort_Message+="httpd.conf.d file"
    if [ ${Recursive_Flag} -eq 0 ]; then
        Abort_Message+="s"
    fi
    Abort_Message+=" or html director"
    if [ ${Recursive_Flag} -eq 0 ]; then
        Abort_Message+="ies"
    else
        Abort_Message+="y"
    fi
    if [ ${Recursive_Flag} -eq 0 ]; then
        Abort_Message+=" from "
    else
        Abort_Message+=" in "
    fi
    Abort_Message+="${Here}, try using --force"
    if [ ${Force_Flag} -eq 0 ]; then
        Vhosts=(${Here})
    else
        aborting "${Abort_Message}"
    fi
fi

Vhost_Count=0

for Vhost in "${Vhosts[@]}"; do
    debugValue Vhost 3 start

    Vhost_Continue=1

    if [ "${Vhost_Ignores}" == "" ]; then
        debug "Default_Vhost_Ignores = $(echo ${Default_Vhost_Ignores[@]})" 24
        Vhost_Ignores=(${Default_Vhost_Ignores[@]})
    fi
    debug "Vhost_Ignores = $(echo ${Vhost_Ignores[@]})" 24

    for Vhost_Ignore in ${Vhost_Ignores[@]}; do
        if [ ${Vhost_Continue} -ne 1 ]; then continue; fi
        Vhost_Skip=$(echo "${Vhost}" | egrep -e "/${Vhost_Ignore}$|/${Vhost_Ignore}/")
        debugValue Vhost_Skip 24 "${Vhost_Ignore}"

        if [ ${Vhost_Continue} -eq 1 ] && [ "${Vhost_Skip}" != "" ]; then
            warning "IGNORE ${Vhost}"
            Vhost_Continue=0
        else
            debugValue Vhost_Ignore 24 "not in ${Vhost}"
        fi
    done

    if [ ${Vhost_Continue} -ne 1 ]; then
        continue
    fi

    let Vhost_Count=${Vhost_Count}+1

    if [ -f "${Vhost}/httpd.conf.d.documentroot.custom" ]; then
        Vhost_Document_Root=$(cat "${Vhost}/httpd.conf.d.documentroot.custom" | grep -v "^#" | head -1 | awk '{print $1}')
        Vhost=$(dirname "${Vhost_Document_Root}")
    else
        if type -P base-data &> /dev/null; then
            Vhost_Document_Root=$(base-data -r ${Vhost} 2> /dev/null)
        else
            Vhost_Document_Root="${Vhost}/html"
        fi
    fi

    Vhost_Httpd_Conf_D="${Vhost}/httpd.conf.d"
    if [ ! -f "${Vhost_Httpd_Conf_D}" ]; then
        warning "${Vhost_Httpd_Conf_D} file not found"
        continue
    fi
    debugValue Vhost_Httpd_Conf_D 2

    if [ ${Search_Flag} -eq 0 ] && [ "${Domain_Name}" != "" ]; then

        if [ -s "${Vhost_Httpd_Conf_D}" ]; then
            debugValue Vhost_Httpd_Conf_D 14 "search found"

            Found_Server_Alias=$(grep "ServerAlias ${Domain_Name}$" "${Vhost_Httpd_Conf_D}"*)
            if [ "${Found_Server_Alias}" != "" ]; then
                echo; echo "${Domain_Name} is a ServerAlias in ${Vhost_Httpd_Conf_D}"
            else
                Found_Server_IP=$(grep "<VirtualHost\ [0-9]" "${Vhost_Httpd_Conf_D}"* | awk -F: '{print $(NF-1)}' | awk '{print $NF}')
                if [ "${Found_Server_IP}" != "" ]; then
                    echo; echo "${Domain_Name} has a Server IP in ${Vhost_Httpd_Conf_D} (${Found_Server_IP})"
                fi
                Found_Server_IP=""
                Found_Server_Name=$(grep "ServerName ${Domain_Name}$" "${Vhost_Httpd_Conf_D}"*)
                if [ "${Found_Server_Name}" != "" ]; then
                    echo; echo "${Domain_Name} is a ServerName in ${Vhost_Httpd_Conf_D}"
                fi
                Found_Server_Name=""
            fi
            Found_Server_Alias=""
        else
            debugValue Vhost_Httpd_Conf_D 14 "search missing"
        fi
        continue # search, don't configure, continue
    fi

    debugValue Vhost 3 final

    if type -P base-data &> /dev/null; then
        Vhost_Account=$(base-data -a ${Vhost} 2> /dev/null)
    else
        Vhost_Account=$(echo -n "${Vhost}" | awk -F/ '{print $3}')
        if [ "${Vhost_Account}" == "account" ]; then
            Vhost_Account=$(echo -n "${Vhost}" | awk -F/ '{print $4}')
        else
            Vhost_Account="apex"
        fi

        if [ "${Vhost_Account}" == "" ]; then
            aborting "Vhost_Account is null"
        fi
    fi

    debugValue Vhost_Account 3

    if [ "${Domain_Name}" == "" ]; then

        if [ -r "${Vhost}/httpd.conf.d" ]; then
            Vhost_Domain_Name=$(grep ServerName "${Vhost}/httpd.conf.d" | head -1 | awk '{print $NF}')

            debugValue Vhost_Domain_Name 9 1a
        fi

        if [ ${#Vhost_Domain_Name} -eq 0 ]; then
            if type -P base-data &> /dev/null; then
                Vhost_Domain_Name=$(base-data -d ${Vhost} 2> /dev/null)
            else
                Vhost_Domain_Name="$(basename $(realpath ${Vhost}))"

                debugValue Vhost_Domain_Name 9 1b

                if [ "${Vhost_Domain_Name}" == "@" ]; then
                    Vhost_Domain_Name="$(basename $(realpath $(dirname ${Vhost})))"
                    debugValue Vhost_Domain_Name 9 2b
                else
                    Vhost_Domain_Name+=".$(basename $(realpath $(dirname ${Vhost})))"
                    debugValue Vhost_Domain_Name 9 3b
                fi

                if [ "${Vhost_Domain_Name}" == "account" ]; then
                    Vhost_Domain_Name=""
                fi
            fi
        fi

    else
        Vhost_Domain_Name="${Domain_Name}"
    fi

    if [ "${Vhost_Domain_Name}" == "" ]; then
        aborting "Vhost_Domain_Name is null"
    fi
    debugValue Vhost_Domain_Name 3

    Vhost_TLDN=$(echo "${Vhost_Domain_Name}" | awk -F. '{print $(NF-1)"."$NF}')
    debugValue Vhost_TLDN 13

    if [ "$(dirname "${Vhost_Document_Root}")" != "${Vhost}" ]; then
        aborting "${Vhost} invalid document root ${Vhost_Document_Root}"
    fi

    debugValue Vhost_Document_Root 3

    #if type -P base-data &> /dev/null; then
        #Vhost_Prefix=$(base-data -p ${Vhost} 2> /dev/null)
    #else
        Vhost_Prefix="${Vhost_Account}.${Vhost_Domain_Name}"
    #fi

    if [ "${Vhost_Prefix}" == "" ]; then
        aborting "Vhost_Prefix is null"
    fi

    debugValue Vhost_Prefix 3

    if [ -f "${Vhost}"/httpd.conf.d ]; then
        Vhost_Server_IP="$(grep "<VirtualHost\ " "${Vhost}/httpd.conf.d" | awk -F: '{print $(NF-1)}' | awk '{print $NF}' | sort -u)"
        debugValue Vhost_Server_IP 20 "found"
    fi

    if [ "${Vhost_Server_IP}" == "" ]; then
        Vhost_Server_IP="*"
        debugValue Vhost_Server_IP 20 "set it to wildcard"
    fi

    if [ "${IP}" != "" ]; then
        if [ "${Vhost_Server_IP}" != "${IP}" ]; then
            warning "${IP} is not ${Vhost_Server_IP}"
            question "Use ${IP} for ${Vhost} VirtualHost bindings"
            if [ "${Question_Flag}" -eq 0 ]; then
                Vhost_Server_IP="${IP}"
            fi
        fi
    fi

    if [ -f "${Vhost_Httpd_Conf_D}.name.custom" ]; then
        Vhost_Server_Name=$(cat "${Vhost_Httpd_Conf_D}.name.custom" | grep -v "^#" | head -1 | awk '{print $1}')
    else
        if type -P base-data &> /dev/null; then
            Vhost_Server_Name=$(base-data -s ${Vhost} 2> /dev/null)
        else
            Vhost_Server_Name="${Vhost_Domain_Name}"
        fi
    fi

    if [ "${Vhost_Server_Name}" == "" ]; then
        aborting "Vhost_Server_Name is null"
    fi

    debugValue Vhost_Server_Name 1

    if [ "${Vhost_Vhosts_Custom_80}" == "" ] && [ -f "${Vhost}/httpd.conf.d.vhosts.custom.80" ]; then
        Vhost_Vhosts_Custom_80="include ${Vhost}/httpd.conf.d.vhosts.custom.80"
    fi

    if [ "${Vhost_Vhosts_Custom_80}" == "" ] && [ -f "${Vhost}/httpd.conf.d.vhosts.custom" ]; then
        Vhost_Vhosts_Custom_80="include ${Vhost}/httpd.conf.d.vhosts.custom"
    fi

    if [ "${Vhost_Vhosts_Custom_80}" == "" ]; then
        Vhost_Vhosts_Custom_80="#include ${Vhost}/httpd.conf.d.vhosts.custom.80 file not found"
    fi

    if [ "${Vhost_Vhosts_Custom_443}" == "" ] && [ -f "${Vhost}/httpd.conf.d.vhosts.custom.443" ]; then
        Vhost_Vhosts_Custom_443="include ${Vhost}/httpd.conf.d.vhosts.custom.443"
    fi

    if [ "${Vhost_Vhosts_Custom_443}" == "" ] && [ -f "${Vhost}/httpd.conf.d.vhosts.custom" ]; then
        Vhost_Vhosts_Custom_443="include ${Vhost}/httpd.conf.d.vhosts.custom"
    fi

    if [ "${Vhost_Vhosts_Custom_443}" == "" ]; then
        Vhost_Vhosts_Custom_443="#include ${Vhost}/httpd.conf.d.vhosts.custom.443 file not found"
    fi

    debugValue Vhost_Vhosts_Custom_80 2
    debugValue Vhost_Vhosts_Custom_443 2

    # start validating the directory, files, etc.

    echo

    vhostEcho "[OK] found ServerName ${Vhost_Server_Name}"
    vhostEcho "[OK] found Server IP ${Vhost_Server_IP}"

    if [ -d "${Vhost}" ]; then
        debug "[OK] found vhost directory" 10
    else
        vhostEcho "[ERROR] missing vhost directory"
    fi

    if [ "${Vhost_Dirs}" == "" ]; then
        debug "Default_Vhost_Dirs = $(echo ${Default_Vhost_Dirs[@]})" 20
        Vhost_Dirs=(${Default_Vhost_Dirs[@]})
        Vhost_Peer_Dirs=(config content etc files log logs nbproject surveys upload uploads vendor) # these may, or may not exist

            for Vhost_Peer_Dir in ${Vhost_Peer_Dirs[@]}; do
                if [ -d "${Vhost}/${Vhost_Peer_Dir}" ]; then
                    Vhost_Dirs+=(${Vhost_Peer_Dir})
                fi
            done
            Vhost_Peer_Dir=""
    fi
    debug "Vhost_Dirs = $(echo ${Vhost_Dirs[@]})" 5

    debug "Vhost_Ignores = $(echo ${Vhost_Ignores[@]})" 25

    for Vhost_Dir in ${Vhost_Dirs[@]}; do
        debugValue Vhost_Dir 30
        if [ -d "${Vhost}/${Vhost_Dir}" ]; then
            debug "[OK] found ${Vhost_Dir} directory" 10
        else
            vhostEcho "[ERROR] missing ${Vhost_Dir} directory"
            if [ ${Update_Flag} -eq 0 ]; then
                vhostEcho "[UPDATE] make ${Vhost_Dir} directory"
                mkdir -p "${Vhost}/${Vhost_Dir}"
                if [ $? -ne 0 ]; then
                    vhostEcho "[WARNING] failed to mkdir ${Vhost_Dir}"
                    vhostResetGlobals
                    continue
                fi
                vhostEcho "[UPDATE] svn add ${Vhost_Dir} directory"
                svn add "${Vhost}/${Vhost_Dir}" &> /dev/null
                if [ $? -ne 0 ]; then
                    vhostEcho "[WARNING] failed to svn add ${Vhost_Dir}"
                    vhostResetGlobals
                    continue
                fi
            fi
        fi
    done

    if [ ${Perms_Flag} -eq 0 ]; then
        Vhost_Svn_URL=$(svn info 2> /dev/null | grep URL: | awk -FURL: '{print $NF}')

        if [ -f "${Vhost_Httpd_Conf_D}.permissions.custom" ]; then
            source ${Vhost_Httpd_Conf_D}.permissions.custom
        else
            unset -v Vhost_Owner Vhost_Group Vhost_Mode
        fi

        if [ "${Vhost_Owner}" == "" ]; then
            Vhost_Owner=${Default_Vhost_Owner}
        fi

        if [ "${Vhost_Group}" == "" ]; then
            Vhost_Group=${Default_Vhost_Group}
        fi

        if [ "${Vhost_Mode}" == "" ]; then
            Vhost_Mode=${Default_Vhost_Mode}
        fi

        debugValue Vhost_Owner 2
        debugValue Vhost_Group 2
        debugValue Vhost_Mode 2

        svn propset owner "${Vhost_Owner}" "${Vhost}/httpd.conf.d"* &> /dev/null
        svn propset group "${Vhost_Group}" "${Vhost}/httpd.conf.d"* &> /dev/null

        for Vhost_Dir in ${Vhost_Dirs[@]}; do
            debugValue Vhost_Dir 10 Perms_Flag
            vhostEcho "[UPDATE] svn propset ${Vhost_Dir} directory"
            svn propset owner "${Vhost_Owner}" "${Vhost}/${Vhost_Dir}" &> /dev/null
            if [ $? -eq 0 ]; then
                Perms_Set=0
            fi
            svn propset group "${Vhost_Group}" "${Vhost}/${Vhost_Dir}" &> /dev/null
            if [ $? -eq 0 ]; then
                Perms_Set=0
            fi
            svn propset mode "${Vhost_Mode}" "${Vhost}/${Vhost_Dir}" &> /dev/null
            if [ $? -eq 0 ]; then
                Perms_Set=0
            fi
            Ignore_Props=(log session tmp)

            for Ignore_Prop in ${Ignore_Props[@]}; do
                if [ "${Vhost_Dir}" == "${Ignore_Prop}" ]; then
                    vhostEcho "[UPDATE] svn ignore ${Vhost_Dir} directory"
                    svn propset svn:ignore "*" "${Vhost}/${Vhost_Dir}" &> /dev/null
                    if [ $? -eq 0 ]; then
                        Perms_Set=0
                    fi
                    Rcs_Flag=0
                fi
            done
        done
        vhostEcho "[UPDATE] svn perms ${Vhost}"
        svn perms "${Vhost}" &> /dev/null

    fi

    if [ ${Config_Flag} -eq 0 ]; then

        # these are oreder dependent; the first found will be used
        Vhost_Certificate_File_Candidates=(
            "${Vhost}/certificate/*.${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/*.${Vhost_TLDN}.crt"
            "${Vhost}/certificate/${Vhost_TLDN}.crt"
            "${Vhost}/certificate/ca.${Vhost_Server_Name}.crt"
            "${Vhost}/certificate/ca.${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/ca.*.${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/site.crt"
            "${Vhost}/certificate/ssl.crt"
            "${Vhost}/certificate/localhost.crt"
            "${Vhost}/certificate/ca.crt"
            /etc/pki/tls/certs/localhost.crt
            /etc/pki/tls/certs/ca.crt
        )

        for Vhost_Certifificate_File_Candidate in ${Vhost_Certificate_File_Candidates[@]}; do
            if [ "${Vhost_Certificate_File}" == "" ] && [ -s "${Vhost_Certifificate_File_Candidate}" ]; then
                debugValue Vhost_Certifificate_File_Candidate 20 found
                Vhost_Certificate_File="${Vhost_Certifificate_File_Candidate}"
                break
            else
                debugValue Vhost_Certifificate_File_Candidate 20 "not found"
            fi
        done

        if [ "${Vhost_Certificate_File}" == "" ]; then
            Vhost_Certificate_File="#SSLCertificateFile NOT FOUND"
        else
            Vhost_Certificate_File="SSLCertificateFile ${Vhost_Certificate_File}"
        fi
        debugValue Vhost_Certificate_File 10

        # these are oreder dependent; the first found will be used
        Vhost_Certificate_Chainfile_Candidates=(
            "${Vhost}/certificate/*.${Vhost_Domain_Name}.chain"
            "${Vhost}/certificate/${Vhost_Domain_Name}.chain"
            "${Vhost}/certificate/*.${Vhost_TLDN}.chain"
            "${Vhost}/certificate/${Vhost_TLDN}.chain"
            "${Vhost}/certificate/chain.${Vhost_Server_Name}.crt"
            "${Vhost}/certificate/chain.${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/chain.*.${Vhost_Domain_Name}.crt"
            "${Vhost}/certificate/chain.crt"
        )

        for Vhost_Certificate_Chainfile_Candidate in ${Vhost_Certificate_Chainfile_Candidates[@]}; do
            if [ "${Vhost_Certificate_Chainfile}" == "" ] && [ -s "${Vhost_Certificate_Chainfile_Candidate}" ]; then
                debugValue Vhost_Certificate_Chainfile_Candidate 20 found
                Vhost_Certificate_Chainfile="${Vhost_Certificate_Chainfile_Candidate}"
                break
            else
                debugValue Vhost_Certificate_Chainfile_Candidate 30 failed
            fi
        done

        if [ "${Vhost_Certificate_Chainfile}" == "" ]; then
            Vhost_Certificate_Chainfile="#SSLCertificateChainFile NOT FOUND"
        else
            Vhost_Certificate_Chainfile="SSLCertificateChainFile ${Vhost_Certificate_Chainfile}"
        fi
        debugValue Vhost_Certificate_Chainfile 10

        # these are oreder dependent; the first found will be used
        Vhost_Certificate_Keyfile_Candidates=(
            "${Vhost}/certificate/*.${Vhost_Domain_Name}.key"
            "${Vhost}/certificate/${Vhost_Domain_Name}.key"
            "${Vhost}/certificate/*.${Vhost_TLDN}.key"
            "${Vhost}/certificate/${Vhost_TLDN}.key"
            "${Vhost}/certificate/ca.${Vhost_Server_Name}.key"
            "${Vhost}/certificate/ca.${Vhost_Domain_Name}.key"
            "${Vhost}/certificate/ca.*.${Vhost_Domain_Name}.key"
            "${Vhost}/certificate/site.key"
            "${Vhost}/certificate/ssl.key"
            "${Vhost}/certificate/localhost.key"
            "${Vhost}/certificate/ca.key"
            /etc/pki/tls/private/localhost.key
            /etc/pki/tls/private/ca.key
        )

        for Vhost_Certificate_Keyfile_Candidate in ${Vhost_Certificate_Keyfile_Candidates[@]}; do
            if [ "${Vhost_Certificate_Keyfile}" == "" ] && [ -s "${Vhost_Certificate_Keyfile_Candidate}" ]; then
                debugValue Vhost_Certificate_Keyfile_Candidate 20 found
                Vhost_Certificate_Keyfile="${Vhost_Certificate_Keyfile_Candidate}"
                break
            else
                debugValue Vhost_Certificate_Keyfile_Candidate 30 failed
            fi
        done

        if [ "${Vhost_Certificate_Keyfile}" == "" ]; then
            Vhost_Certificate_Keyfile="#SSLCertificateKeyFile NOT FOUND"
        else
            Vhost_Certificate_Keyfile="SSLCertificateKeyFile ${Vhost_Certificate_Keyfile}"
        fi
        debugValue Vhost_Certificate_Keyfile 10

        debugValue Vhost_Httpd_Conf_D 9
        debugValue Config 9
        debugValue Config_File 9

        if [ "${Vhost_Httpd_Conf_D}" != "" ] && [ -s "${Vhost_Httpd_Conf_D}" ]; then
            Vhost_Config_File_Last=$(head -1 "${Vhost_Httpd_Conf_D}" | awk -Fmd5sum '{print $1}' | awk -F# '{print $NF}' | sed -e 's|[ \t]*$||g' -e 's|^[ \t]*||g')
        else
            vhostEcho "[WARNING] config is empty"
            if [ ${Force_Flag} -eq 1 ]; then
                warning "${Vhost_Httpd_Conf_D} file not found (use --force)"
                if [ ${Recursive_Flag} -eq 0 ]; then
                    vhostResetGlobals
                    continue
                else
                    Abort_Message=""
                    if [ -f "${Vhost_Httpd_Conf_D}" ]; then
                        Abort_Message+="manually remove ${Vhost_Httpd_Conf_D} first, or "
                    fi
                    Abort_Message+="try using the --force flag"
                    aborting "${Abort_Message}"
                fi
            else
                warning "forcing ${Vhost_Httpd_Conf_D} to use template (${Config_File})"
                Vhost_Config_File="${Config_File}"
            fi
        fi

        if [ "${Config}" == "dynamic" ] || [ "${Config}" == "last" ]; then
            if [ -r "${Vhost_Config_File_Last}" ]; then
                Vhost_Config_File="${Vhost_Config_File_Last}"
            else
                Vhost_Config_File_Last=""
            fi
        fi

        debugValue Vhost_Config_File_Last 9

        if [ "${Vhost_Config_File_Last}" == "" ]; then
            vhostEcho "[WARNING] config was not generated from a valid template"
            if [ ${Force_Flag} -eq 1 ]; then
                warning "skipping invalid ${Vhost_Httpd_Conf_D} (use --force)"
                if [ ${Recursive_Flag} -eq 0 ]; then
                    vhostResetGlobals
                    continue
                else
                    aborting "refusing to change ${Vhost_Httpd_Conf_D}, try the --force flag"
                fi
            else
                if [ -r "${Config_File}" ]; then
                    warning "forcing ${Vhost_Httpd_Conf_D} to a new template (${Config_File})"
                    Vhost_Config_File="${Config_File}"
                else
                    warning "unable to force ${Vhost_Httpd_Conf_D} to an unknown template (${Config_File})"
                    Vhost_Config_File=""
                    continue
                fi
            fi
        fi

        if [ "${Vhost_Config_File}" == "" ] && [ "${Vhost_Config_File_Last}" != "${Config_File}" ]; then
            vhostEcho "[WARNING] config was previously generated from a different template (${Vhost_Config_File_Last})"
            if [ ${Force_Flag} -eq 1 ]; then
                warning "skipping ${Vhost_Httpd_Conf_D}"
                if [ ${Recursive_Flag} -eq 0 ]; then
                    vhostResetGlobals
                    continue
                else
                    aborting "manually remove ${Vhost_Httpd_Conf_D} first, or use the --force flag"
                fi
            else
                warning "forcing ${Vhost_Httpd_Conf_D} to a new template (${Config_File})"
                Vhost_Config_File="${Config_File}"
            fi
        else
            if [ "${Vhost_Config_File}" == "" ] && [ -r "${Config_File}" ]; then
                Vhost_Config_File="${Config_File}"
            fi
        fi

        debugValue Vhost_Config_File 9

        if [ "${Vhost_Config_File}" == "" ] || [ ! -r "${Vhost_Config_File}" ]; then
            aborting "transient error determining input config file template"
        else
            vhostEcho "[OK] using template ${Vhost_Config_File}"
        fi

        Vhost_Server_Aliases=()

        Vhost_Server_Aliases+=("www.${Vhost_Server_Name}")
        if [ ${Domain_Name_Flag} -eq 0 ] && [ "${Vhost_Domain_Name}" != "" ]; then
            if [ "${Vhost_Domain_Name}" != "${Vhost_Server_Name}" ]; then
                Vhost_Server_Aliases+=("www.${Vhost_Server_Name}.${Vhost_Domain_Name}")
            fi
        fi

        for Vhost_Server_Alias in ${Vhost_Server_Aliases[@]}; do

            for Server_Alias_Record in ${Server_Alias_Records}; do
                debugValue Server_Alias_Record 20
                if [ "${Server_Alias_Record}" == "prod" ]; then continue; fi
                Vhost_Server_Aliases+=("${Server_Alias_Record}-${Vhost_Server_Alias}")
                Vhost_Server_Aliases+=("${Server_Alias_Record}.${Vhost_Server_Alias}")
                Vhost_Server_Aliases+=("${Server_Alias_Record}-${Vhost_Server_Name}")
                Vhost_Server_Aliases+=("${Server_Alias_Record}.${Vhost_Server_Name}")
                if [ ${Domain_Name_Flag} -eq 0 ] && [ "${Vhost_Domain_Name}" != "" ]; then
                    if [ "${Vhost_Domain_Name}" != "${Vhost_Server_Alias}" ]; then
                        if [ "${Vhost_Domain_Name}" != "${Vhost_Server_Name}" ]; then
                            Vhost_Server_Aliases+=("${Server_Alias_Record}-${Vhost_Server_Alias}.${Vhost_Domain_Name}")
                            Vhost_Server_Aliases+=("${Server_Alias_Record}.${Vhost_Server_Alias}.${Vhost_Domain_Name}")
                        fi
                    fi
                    if [ "${Vhost_Domain_Name}" != "${Vhost_Server_Name}" ]; then
                        if [ "${Vhost_Domain_Name}" != "${Vhost_Server_Name}" ]; then
                            Vhost_Server_Aliases+=("${Server_Alias_Record}-${Vhost_Server_Name}.${Vhost_Domain_Name}")
                            Vhost_Server_Aliases+=("${Server_Alias_Record}.${Vhost_Server_Name}.${Vhost_Domain_Name}")
                        fi
                    fi
                fi
            done
        done

        Vhost_Server_Aliases_Unique=$(echo "${Vhost_Server_Aliases[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        debugValue Vhost_Server_Aliases_Unique 27

        Vhost_Server_Aliases=(${Vhost_Server_Aliases_Unique[@]})

        # make sure configs generated with this script have a consistent header line
        Vhost_Config_File_MD5==$(md5sum "${Vhost_Config_File}" | awk '{print $1}')
        echo "# ${Vhost_Config_File} md5sum ${Vhost_Config_File_MD5}" > "${Vhost_Httpd_Conf_D}"

        sed "${Vhost_Config_File}" \
            -e "s|##ACCOUNT##|${Vhost_Account}|g" \
            -e "s|##CONFIG##|${Config}|g" \
            -e "s|##CONFIG_FILE##|${Vhost_Config_File}|g" \
            -e "s|##CONFIG_FILE_MD5##|${Vhost_Config_File_MD5}|g" \
            -e "s|##CERTIFICATE_FILE##|${Vhost_Certificate_File}|g" \
            -e "s|##CERTIFICATE_CHAINFILE##|${Vhost_Certificate_Chainfile}|g" \
            -e "s|##CERTIFICATE_KEYFILE##|${Vhost_Certificate_Keyfile}|g" \
            -e "s|##DOCUMENT_ROOT##|${Vhost_Document_Root}|g" \
            -e "s|##PREFIX##|${Vhost_Prefix}|g" \
            -e "s|##SERVER_IP##|${Vhost_Server_IP}|g" \
            -e "s|##SERVER_NAME##|${Vhost_Server_Name}|g" \
            -e "s|##VHOSTS_CUSTOM_80##|${Vhost_Vhosts_Custom_80}|g" \
            -e "s|##VHOSTS_CUSTOM_443##|${Vhost_Vhosts_Custom_443}|g" \
            | sed \
            -e 's|[ \t]*$||g' \
            -e 's|^[ \t]*$||g' \
            >> "${Vhost_Httpd_Conf_D}"

        if [ $? -ne 0 ]; then
            aborting "sed failed; ${Vhost_Httpd_Conf_D} is probably broken" 1
        fi

        echo "# WARNING! DO NOT EDIT THIS FILE  It was automatically generated by $0" > "${Vhost_Httpd_Conf_D}.aliases.automatic"
        if [ -f "${Vhost_Httpd_Conf_D}.aliases.custom" ]; then
            echo "include ${Vhost_Httpd_Conf_D}.aliases.custom" >> "${Vhost_Httpd_Conf_D}.aliases.automatic"
        fi

        for Vhost_Server_Alias in ${Vhost_Server_Aliases[@]}; do
            debugValue Vhost_Server_Alias 10
            echo "ServerAlias ${Vhost_Server_Alias}" >> "${Vhost_Httpd_Conf_D}.aliases.automatic"
        done

        if [ -f "${Vhost_Httpd_Conf_D}.aliases.automatic" ]; then

            sed -i "${Vhost_Httpd_Conf_D}" \
                -e "s|##SERVER_ALIASES##|include ${Vhost_Httpd_Conf_D}.aliases.automatic|g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        fi

        if [ $? -ne 0 ]; then
            aborting "sed failed; ${Vhost_Httpd_Conf_D} is probably broken" 3
        else
            Rcs_Flag=0
        fi

        vhostEcho "[OK] created httpd.conf.d.aliases.automatic"

        if [ -f "${Vhost_Httpd_Conf_D}.acl.custom" ]; then
            vhostEcho "[OK] embedded httpd.conf.d.acl.custom"

            sed -i "${Vhost_Httpd_Conf_D}" \
                -e "s|##ACCESS_CONTROL_LIST##|include ${Vhost_Httpd_Conf_D}.acl.custom|g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        else

            sed -i "${Vhost_Httpd_Conf_D}" \
                -e "s|##ACCESS_CONTROL_LIST##||g" \
                -e 's|[ \t]*$||g' \
                -e 's|^[ \t]*$||g'

        fi

        sed -i '/^$/N;/^\n$/D' "${Vhost_Httpd_Conf_D}" # collapse blank lines

        if [ $? -ne 0 ]; then
            aborting "sed failed; ${Vhost_Httpd_Conf_D} is probably broken" 3
        else
            Rcs_Flag=0
        fi

        vhostEcho "[OK] created httpd.conf.d ($(basename "${Vhost_Config_File}"))"
    fi

    if [ -s "${Vhost_Httpd_Conf_D}" ]; then
        vhostEcho "[OK] ${Vhost_Httpd_Conf_D}"
    else
        vhostEcho "[ERROR] missing httpd.conf.d"
        if [ ${Update_Flag} -eq 0 ]; then
            vhostEcho "[UPDATE] !!! create httpd.conf.d !!! [not done yet]"
        else
            vhostResetGlobals
            continue
        fi
    fi

    # check DocumentRoot statements
    if [ -s "${Vhost_Httpd_Conf_D}" ]; then

        while read Vhost_Httpd_Conf_D_Document_Root; do
            debugValue Vhost_Httpd_Conf_D_Document_Root 10
            if [ "${Vhost_Httpd_Conf_D_Document_Root}" == "${Vhost_Document_Root}" ]; then
                debug "[OK] found DocumentRoot '${Vhost_Httpd_Conf_D_Document_Root}'" 10
            else
                vhostEcho "[WARNING] incorrect DocumentRoot '${Vhost_Httpd_Conf_D_Document_Root}'"
                break;
            fi
        done <<< "$(grep DocumentRoot "${Vhost_Httpd_Conf_D}" | egrep -ve '^#' | awk -F# '{print $1}' | awk -FDocumentRoot '{print $NF}' | sed -e '/"/s///g' -e '/^[ \t]*/s///g')"
    fi

    # check CustomLog statements
    if [ -s "${Vhost_Httpd_Conf_D}" ]; then
        Vhost_Prefix_Account_Log="/var/log/httpd/${Vhost_Account}"
        debugValue Vhost_Prefix_Account_Log 10

        Vhost_Prefix_Custom_Log="/var/log/httpd/${Vhost_Prefix}.access"
        debugValue Vhost_Prefix_Custom_Log 10

        while read Vhost_Httpd_Conf_D_Custom_Log_Entry; do
            debugValue Vhost_Httpd_Conf_D_Custom_Log_Entry 10

            Vhost_Prefix_Custom_Log_Format=$(echo "${Vhost_Httpd_Conf_D_Custom_Log_Entry}" | awk '{print $2}')
            if [ "${Vhost_Prefix_Custom_Log_Format}" == "" ]; then
                Vhost_Prefix_Custom_Log_Format="combined"
            fi
            debugValue Vhost_Prefix_Custom_Log_Format 10

            Vhost_Httpd_Conf_D_Custom_Log=$(echo "${Vhost_Httpd_Conf_D_Custom_Log_Entry}" | awk '{print $1}')
            debugValue Vhost_Httpd_Conf_D_Custom_Log 10

            if [ "${Vhost_Httpd_Conf_D_Custom_Log}" == "" ]; then continue; fi

            Vhost_Httpd_Conf_D_Custom_Log_443=$(cat "${Vhost_Httpd_Conf_D}" | egrep -e "\<VirtualHost|CustomLog" | grep -B1 "${Vhost_Httpd_Conf_D_Custom_Log}" | head -1 | awk -FVirtualHost '{print $NF}' | grep 443)
            if [ "${Vhost_Httpd_Conf_D_Custom_Log_443}" == "" ]; then
                # assume port 80
                Vhost_Httpd_Conf_D_Custom_Log_Port="80"
            else
                # definitely port 443
                Vhost_Httpd_Conf_D_Custom_Log_Port="443"
            fi
            debugValue Vhost_Httpd_Conf_D_Custom_Log_Port 10

            if [ "${Vhost_Prefix_Custom_Log_Format}" == "combined" ]; then
                Vhost_Custom_Log="${Vhost_Prefix_Custom_Log}.${Vhost_Httpd_Conf_D_Custom_Log_Port}.log"
            else
                Vhost_Custom_Log="${Vhost_Prefix_Account_Log}.${Vhost_Httpd_Conf_D_Custom_Log_Port}.log"
            fi
            debugValue Vhost_Custom_Log 10

            Vhost_Prefix_Custom_Log_Match=$(echo "${Vhost_Httpd_Conf_D_Custom_Log}" | egrep -e "^${Vhost_Custom_Log}\ |${Vhost_Custom_Log}$")

            if [ "${Vhost_Prefix_Custom_Log_Match}" != "" ]; then
                debug "[OK] found CustomLog (${Vhost_Httpd_Conf_D_Custom_Log_Port} ${Vhost_Prefix_Custom_Log_Format})" 10
            else
                vhostEcho "[WARNING] incorrect CustomLog '${Vhost_Httpd_Conf_D_Custom_Log}' (${Vhost_Httpd_Conf_D_Custom_Log_Port} ${Vhost_Prefix_Custom_Log_Format})"
                if [ ${Etc_Flag} -eq 0 ]; then
                    vhostEcho "[UPDATE] correct CustomLog '${Vhost_Custom_Log}' (${Vhost_Httpd_Conf_D_Custom_Log_Port} ${Vhost_Prefix_Custom_Log_Format})"
                    sed -i "s#${Vhost_Httpd_Conf_D_Custom_Log}#${Vhost_Custom_Log}#g" "${Vhost_Httpd_Conf_D}"
                    Rcs_Flag=0
                fi
            fi

            Vhost_Prefix_Custom_Log_Format=""
        done <<< "$(grep CustomLog "${Vhost_Httpd_Conf_D}" | egrep -ve '^#' | awk -F# '{print $1}' | awk -FCustomLog '{print $NF}')"

    fi

    # check ErrorLog statements
    if [ -s "${Vhost_Httpd_Conf_D}" ]; then
        Vhost_Prefix_Error_Log="/var/log/httpd/${Vhost_Prefix}.error"
        debugValue Vhost_Prefix_Error_Log 10

        while read Vhost_Httpd_Conf_D_Error_Log; do
            debugValue Vhost_Httpd_Conf_D_Error_Log 10

            Vhost_Httpd_Conf_D_Error_Log_443=$(cat "${Vhost_Httpd_Conf_D}" | egrep -e "\<VirtualHost|ErrorLog" | grep -B1 "${Vhost_Httpd_Conf_D_Error_Log}" | head -1 | awk -FVirtualHost '{print $NF}' | grep 443)
            if [ "${Vhost_Httpd_Conf_D_Error_Log_443}" == "" ]; then
                # assume port 80
                Vhost_Httpd_Conf_D_Error_Log_Port="80"
            else
                # definitely port 443
                Vhost_Httpd_Conf_D_Error_Log_Port="443"
            fi
            debugValue Vhost_Httpd_Conf_D_Error_Log_Port 10

            Vhost_Error_Log="${Vhost_Prefix_Error_Log}.${Vhost_Httpd_Conf_D_Error_Log_Port}.log"
            debugValue Vhost_Error_Log 10

            Vhost_Prefix_Error_Log_Match=$(echo "${Vhost_Httpd_Conf_D_Error_Log}" | grep ^"${Vhost_Error_Log}")

            if [ "${Vhost_Prefix_Error_Log_Match}" != "" ]; then
                debug "[OK] found ErrorLog (${Vhost_Httpd_Conf_D_Error_Log_Port})" 10
            else
                vhostEcho "[WARNING] incorrect ErrorLog '${Vhost_Httpd_Conf_D_Error_Log}' (${Vhost_Httpd_Conf_D_Error_Log_Port})"
                if [ ${Etc_Flag} -eq 0 ]; then
                    vhostEcho "[UPDATE] correct ErrorLog '${Vhost_Error_Log}' (${Vhost_Httpd_Conf_D_Error_Log_Port})"
                    sed -i "s#${Vhost_Httpd_Conf_D_Error_Log}#${Vhost_Error_Log}#g" "${Vhost_Httpd_Conf_D}"
                    Rcs_Flag=0
                fi
            fi
        done <<< "$(grep ErrorLog "${Vhost_Httpd_Conf_D}" | egrep -ve '^#' | awk -F# '{print $1}' | awk -FErrorLog '{print $NF}' | sed -e '/"/s///g' -e '/^[ \t]*/s///g')"
    fi

    if [ ${Etc_Flag} -eq 0 ]; then
        Vhost_Etc_Httpd_Conf_D_Dirs+=" /etc/httpd/conf.d"
    fi
    if [ "${Machine_Flag}" -eq 0 ] && [ "${Machine}" != "" ]; then
        if [ ! -d "${Apex_Dir}/machine/${Machine}/etc/httpd/conf.d" ]; then
            mkdir -p "${Apex_Dir}/machine/${Machine}/etc/httpd/conf.d"
            if [ $? -ne 0 ]; then
                aborting "${Apex_Dir}/machine/${Machine}/etc/httpd/conf.d mkdir failed" 2
            fi
        fi
        Vhost_Etc_Httpd_Conf_D_Dirs+=" ${Apex_Dir}/machine/${Machine}/etc/httpd/conf.d"
    fi
    Vhost_Etc_Httpd_Conf_D_Dirs=$(listUnique "${Vhost_Etc_Httpd_Conf_D_Dirs}")
    debugValue Vhost_Etc_Httpd_Conf_D_Dirs 20

    for Vhost_Etc_Httpd_Conf_D_Dir in ${Vhost_Etc_Httpd_Conf_D_Dirs}; do

        # validate the links in Vhost_Etc_Httpd_Conf_D_Dir are correct (& fix them if necessary)

        if [ -d "${Vhost_Etc_Httpd_Conf_D_Dir}" ]; then
            if [ "${Vhost_Prefix}" == "" ]; then
                aborting "Vhost_Prefix is null"
            fi

            debugValue Vhost_Etc_Httpd_Conf_D_Dir 10

            Vhost_Etc_Httpd_Conf_D="${Vhost_Etc_Httpd_Conf_D_Dir}/${Vhost_Prefix}.conf"
            debugValue Vhost_Etc_Httpd_Conf_D 10

            if [ -f "${Vhost_Etc_Httpd_Conf_D}" ] || [ -h "${Vhost_Etc_Httpd_Conf_D}" ]; then
                Vhost_Etc_Httpd_Conf_D_Link="$(find "${Vhost_Etc_Httpd_Conf_D}" -type l -printf '%h/%f')"

                if [ "${Vhost_Etc_Httpd_Conf_D}" == "${Vhost_Etc_Httpd_Conf_D_Link}" ]; then
                    vhostEcho "[OK] found link ${Vhost_Etc_Httpd_Conf_D}" 1
                    continue
                else
                    vhostEcho "[ERROR] incorrect link ${Vhost_Etc_Httpd_Conf_D} (${Vhost_Etc_Httpd_Conf_D_Link})"
                    if [ -s "${Vhost_Httpd_Conf_D}" ]; then
                        if [ ${Etc_Flag} -eq 0 ] || [ ${Machine_Flag} -eq 0 ]; then
                            vhostEcho "[UPDATE] remove link ${Vhost_Etc_Httpd_Conf_D}"
                            rm -f "${Vhost_Etc_Httpd_Conf_D}"
                            if [ $? -ne 0 ]; then
                                vhostEcho "[ERROR] failed to remove ${Vhost_Etc_Httpd_Conf_D}"
                                continue
                            else
                                Rcs_Flag=0
                            fi
                        fi
                    fi
                fi
                Vhost_Etc_Httpd_Conf_D_Link=""
            fi

            if [ ! -f "${Vhost_Etc_Httpd_Conf_D}" ] && [ ! -h "${Vhost_Etc_Httpd_Conf_D}" ]; then
                vhostEcho "[WARNING] missing link ${Vhost_Etc_Httpd_Conf_D}"
                if [ ${Etc_Flag} -eq 0 ] || [ ${Machine_Flag} -eq 0 ]; then
                    if [ ! -f "${Vhost_Etc_Httpd_Conf_D}" ] && [ ! -h "${Vhost_Etc_Httpd_Conf_D}" ] && [ -s "${Vhost_Httpd_Conf_D}" ]; then
                        vhostEcho "[UPDATE] link ${Vhost_Etc_Httpd_Conf_D}"
                        ln -s "${Vhost_Httpd_Conf_D}" "${Vhost_Etc_Httpd_Conf_D}"
                        if [ $? -ne 0 ]; then
                            vhostEcho "[ERROR] failed to link ${Vhost_Etc_Httpd_Conf_D}"
                            vhostResetGlobals
                            continue
                        else
                            Rcs_Flag=0
                        fi
                    fi
                fi
            fi

        fi

    done

    vhostResetGlobals

done

if [ ${Etc_Flag} -eq 0 ] || [ ${Link_Flag} -eq 0 ]; then
    Link_Check_Dirs=""
    Link_Check_Dirs+="/etc/httpd/conf.d/"
    if [ "${Machine}" != "" ]; then
        Link_Check_Dirs+=" ${Apex_Dir}/machine/${Machine}/etc/httpd/conf.d/"
    fi
    debugValue Link_Check_Dirs 20

    for Link_Check_Dir in ${Link_Check_Dirs}; do
        if [ ! -d "${Link_Check_Dir}" ]; then continue; fi
        Broken_Links=`find ${Link_Check_Dir} -type l -xtype l`
        if [ "${Broken_Links}" != "" ]; then
            warning "Removing broken symbolic links in ${Link_Check_Dir} ..."

            for Broken_Link in ${Broken_Links}; do
                if [ -f "${Broken_Link}" ] || [ -h "${Broken_Link}" ]; then
                    echo "Removing broken symlink link ${Broken_Link} ..."
                    svn rm "${Broken_Link}" &> /dev/null
                    if [ -f "${Broken_Link}" ] || [ -h "${Broken_Link}" ]; then
                        rm -f "${Broken_Link}"
                    fi
                    Rcs_Flag=0
                fi
            done
        fi
    done
fi

if [ ${Config_Flag} -eq 0 ]; then
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

if [ ${Rcs_Flag} -eq 0 ]; then
    echo
    echo "NOTE: changes were made; however add & commit must be manually executed"
fi

if [ ${Perms_Flag} -eq 0 ] && [ ${Perms_Set} -eq 0 ]; then
    echo
    echo "NOTE: svn properties were set; commit must be manually executed"
fi

echo
apexFinish 0
