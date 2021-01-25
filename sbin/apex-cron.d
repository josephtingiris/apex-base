#!/bin/bash

# This script will ... find cron.d run-parts directories & add/check them into svn, set perms, etc

# begin Apex.bash.include

if [ "$Debug" == "" ]; then
    Debug=0
fi

Apex_Bash="/apex/include/Apex.bash"
if [ ! -r "$Apex_Bash" ]; then
    echo "$Apex_Bash not readable"
    exit 1;
fi
source "$Apex_Bash"

# end Apex.bash.include

# Global_Variables

# explicit declarations

declare -x Default_Date=`date +%Y%m%d`

declare -i Return_Code=0

declare -x Version="0.1";

# Function_Names

# Validation Logic

dependency "/apex/bin/svn"

# typically, upgrade before optionArguments, begin, etc

# upgrade "$0" "/apex/bin /usr/local/bin"

# optionArguments Logic

# add usage help to the Apex_Usage array (before usage() is called for the first time [via optionArguments])

Apex_Usage+=("-e | --edit                         = before parsing, edit cron.d files (with vim)")
Apex_Usage+=("")
Apex_Usage+=("-c | --commit                       = svn commit cron.d files")
Apex_Usage+=("-p | --perms                        = svn set & run perms")
Apex_Usage+=("")
Apex_Usage+=("-t | --test                         = don't actually do anything")

# call the optionArguments function (to process common options, i.e. --debug, --help, --usage, --yes, etc)

optionArguments $@

# expand upon the optionArguments function (careful, same named switches will be processed twice)

# for each cli option (argument), evaluate them case by case, process them, and shift to the next

declare -i Account_Flag=1
declare -i Commit_Flag=1
declare -i Edit_Flag=1
declare -i Perms_Flag=1
declare -i Test_Flag=1

declare -i Option_Arguments_Index=0
declare -i Option_Arguments_Shift=0
for Option_Argument in ${Option_Arguments[@]}; do

    if [ $Option_Arguments_Shift -eq 1 ]; then
        ((Option_Arguments_Index++))
        Option_Arguments_Shift=0
        continue
    fi

    Option_Argument_Next="${Option_Arguments[$Option_Arguments_Index+1]}"

    case "$Option_Argument" in
        -a | --account | -account)
            # supports an argument with one or more value(s)
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Account+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Account="$(listUnique "$Account")"
            if [ "$Account" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Account_Flag=0
            debugValue Account_Flag 2 "$Option_Argument flag was set [$Account]"
            ;;

        -c | --commit | -commit | commit)
            if [ $Commit_Flag -eq 0 ]; then
                usage "$Option_Argument may only be given once"
            fi
            if [ "$Option_Argument_Next" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "$Option_Argument argument does not accept values"
                fi
            fi
            Commit_Flag=0
            debugValue Commit_Flag 2 "$Option_Argument flag was set"
            ;;

        -e | --edit | -edit | edit)
            if [ $Edit_Flag -eq 0 ]; then
                usage "$Option_Argument may only be given once"
            fi
            if [ "$Option_Argument_Next" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "$Option_Argument argument does not accept values"
                fi
            fi
            Edit_Flag=0
            debugValue Edit_Flag 2 "$Option_Argument flag was set"
            ;;

        -p | --perms | -perms | perms)
            if [ $Perms_Flag -eq 0 ]; then
                usage "$Option_Argument may only be given once"
            fi
            if [ "$Option_Argument_Next" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "$Option_Argument argument does not accept values"
                fi
            fi
            Perms_Flag=0
            debugValue Perms_Flag 2 "$Option_Argument flag was set"
            ;;

        -t | --test | -test | test)
            Test_Flag=1
            if [ $Test_Flag -eq 0 ]; then
                usage "$Option_Argument may only be given once"
            fi
            if [ "$Option_Argument_Next" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "$Option_Argument argument does not accept values"
                fi
            fi
            Test_Flag=0
            debugValue Test_Flag 2 "$Option_Argument flag was set"
            ;;

        *)
            # unsupported arguments
            if [ "$Option_Argument" != "" ]; then
                echo "unsupported argument '$Option_Argument'"
                apexFinish 2
            fi
            ;;

        esac

        ((Option_Arguments_Index++))
    done
    unset Option_Argument_Next Option_Arguments_Index Option_Arguments_Shift

    # e.g., if there are no arguments, echo a usage message and/or exit

    if [ $Apex_Arguments_Count -eq 0 ]; then usage; fi
    if [ $Apex_Arguments_Count -eq 1 ] && [ $Debug_Flag -ne 1 ]; then usage; fi
    if [ $Apex_Arguments_Count -eq 2 ] && [ $Debug_Flag -ne 1 ] && [ "$Debug" != "" ]; then usage; fi

    # Main Logic

    apexStart

    if [ ! -d "$Apex_Dir" ] || [ "$Apex_Dir" == "" ]; then
        aborting "apex directory not found"
    fi

    if [ ! -d "$Apex_Account_Dir" ] || [ "$Apex_Account_Dir" == "" ]; then
        aborting "account directory not found"
    fi

    if [ $Test_Flag -eq 1 ] && [ $Yes_Flag -eq 1 ]; then
        question "this makes changes to cron.d files; continue"
        if [ "$Question_Flag" -ne 0 ]; then
            aborting "nothing done"
        fi
    fi

    Etc_Dirs=()

    if [ $Account_Flag -eq 0 ]; then

        if [ "$Account" == "" ] || [ "$Account" == "apex" ]; then
            if [ -d "${Apex_Dir}/etc" ]; then
                Etc_Dirs+=("${Apex_Dir}/etc")
            fi

            if [ "$Account" == "" ]; then
                for Apex_Account_Dir_Etc in $(ls -1 "${Apex_Account_Dir}"); do
                    if [ -d "${Apex_Account_Dir}/${Apex_Account_Dir_Etc}/etc" ]; then
                        Etc_Dirs+=("${Apex_Account_Dir}/${Apex_Account_Dir_Etc}/etc")
                    fi
                done
            fi
        else
            if [ -d "${Apex_Dir}/account/${Account}/etc" ]; then
                Etc_Dirs+=("${Apex_Dir}/account/${Account}/etc")
            fi
        fi

    else

        Etc_Dirs+="/etc"

    fi

    if [ "$Etc_Dirs" == "" ]; then
        aborting "could not find any matching cron.d directories"
    fi

    let Etc_Counter=0
    for Etc_Dir in ${Etc_Dirs[@]}; do

        debugValue Etc_Dir 3 $Here

        Cron_D_Dir="${Etc_Dir}/cron.d"

        if [ ! -d "${Cron_D_Dir}" ]; then
            # nothing to do
            continue;
        fi

        let Etc_Counter=$Etc_Counter+1

        cd "${Etc_Dir}"

        echo
        echo "+ [$Etc_Counter][$(pwd)] processing"

        Etc_Svn_Info=$(svn info 2> /dev/null |  grep ^URL:)

        if [ "$Etc_Svn_Info" != "" ]; then

            echo "+ [$Etc_Counter][$(pwd)] svn info"

            if [ $Debug -gt 0 ]; then
                echo
                echo "$Etc_Svn_Info"
                echo
            fi

            echo "+ [$Etc_Counter][$(pwd)] svn up"

            if [ $Test_Flag -eq 1 ]; then
                svn up &> /dev/null
                if [ $? -ne 0 ]; then
                    aborting "svn up $Etc_Dir failed"
                fi
            fi

        fi

        cd "${Cron_D_Dir}"

        echo "+ [$Etc_Counter][$(pwd)] processing"

        Cron_D_Files=$(find . -maxdepth 1 -type f -name "*.cron.d" -o -type l -name "*.cron.d")
        for Cron_D_File_Name in $Cron_D_Files; do

            Cron_D_File="${Cron_D_Dir}/$(basename "$Cron_D_File_Name")"

            if [ ! -f "$Cron_D_File" ]; then
                aborting "undetermined problem"
            fi

            if [ $Edit_Flag -eq 0 ]; then

                echo "+ [$Etc_Counter][$(pwd)] editing $Cron_D_File"

                vim "$Cron_D_File"
            fi

            echo "+ [$Etc_Counter][$(pwd)] parsing $Cron_D_File"

            Run_Parts_Dirs=() # reset

            while read -r Run_Parts; do
                #echo "Run_Parts=$Run_Parts"

                Run_Parts_Dir=$(echo "(" &> /dev/null; echo "$Run_Parts" | awk -Frun-parts '{print $NF}' | awk -F\) '{print $1}')
                Run_Parts_Dir=$(listUnique "$Run_Parts_Dir")

                debugValue Run_Parts_Dir 10

                Cron_User=$(echo "$Run_Parts" | awk '{print $6}')

                if [ "$Cron_User" == "" ]; then
                    warning "cron user is null in $Cron_D_File"
                    continue
                fi

                Cron_User_Home=$(grep ^${Cron_User}: /etc/passwd 2> /dev/null)
                if [ "$Cron_User_Home" == "" ]; then
                    warning "$Cron_User is not in /etc/passwd"
                    exit 1
                fi
                Cron_User_Home=$(grep ^${Cron_User}: /etc/passwd 2> /dev/null | awk -F: '{print $6}')
                if [ "$Cron_User_Home" == "" ] || [ ! -d "$Cron_User_Home" ]; then
                    echo "+ [$Etc_Counter][$(pwd)] mkdir $Cron_User_Home"

                    if [ $Test_Flag -eq 1 ]; then
                        mkdir -p "$Cron_User_Home"
                        chmod 0700 "$Cron_User_Home"
                        chown "$Cron_User" "$Cron_User_Home"
                    fi
                fi

                Cron_User_Passwd=$(grep ^${Cron_User}: /etc/passwd 2> /dev/null)
                if [ "$Cron_User_Passwd" == "" ]; then
                    warning "$Cron_User is not in /etc/passwd"
                    continue
                fi

                Cron_Log="$(echo "$Run_Parts" | awk '{print $NF}')"

                if [ "$Cron_Log" == "" ]; then
                    warning "$Cron_Log is null in $Cron_D_File"
                    continue
                fi

                Cron_Log_Dir=$(dirname "$Cron_Log")

                debugValue Cron_Log_Dir 10

                if [ "$Run_Parts_Dir" == "$Cron_Log_Dir" ]; then
                    aborting "run-parts and cron log directories are identical ($Run_Parts_Dir)"
                fi

                # always do this (before processing Run_Parts_Dir)
                Io_Dirs=("${Cron_Log_Dir}" "${Run_Parts_Dir}")
                for Io_Dir in ${Io_Dirs[@]}; do

                    # no need to do the same directory twice
                    case "${Run_Parts_Dirs[@]}" in
                        *"$Io_Dir"*)
                            continue
                            ;;
                    esac

                    echo "+ [$Etc_Counter][$Io_Dir] checking"

                    if [ ! -d "$Io_Dir" ]; then

                        echo "+ [$Etc_Counter][$(pwd)] mkdir $Io_Dir"

                        if [ $Test_Flag -eq 1 ]; then
                            mkdir -p "$Io_Dir"
                        fi

                    fi

                    if [ ! -d "$Io_Dir" ]; then
                        aborting "'$Io_Dir' directory not found"
                    fi

                    if [ -d "$Io_Dir" ]; then

                        while read User_File; do
                            if [ "$User_File" == "" ]; then
                                continue
                            fi

                            echo "+ [$Etc_Counter][$(pwd)] fixing; chown $User_File to $Cron_User"

                            if [ $Test_Flag -eq 1 ]; then
                                chown "$Cron_User" "$User_File"
                            fi
                        done <<< "$(find "$Io_Dir" ! -user "$Cron_User")"

                    fi

                    Run_Parts_Dirs+=("$Io_Dir")

                    continue

                done

                if [ $Commit_Flag -eq 1 ] && [ $Perms_Flag -eq 1 ]; then
                    continue # no need to proceed
                fi

                cd "$Run_Parts_Dir"

                if [ $Commit_Flag -eq 0 ] || [ $Perms_Flag -eq 0 ]; then

                    if [ "$Etc_Svn_Info" == "" ]; then

                        Run_Parts_Svn_Info=$(svn info 2> /dev/null |  grep ^URL:)

                        if [ "$Run_Parts_Svn_Info" != "" ]; then

                            echo "+ [$Etc_Counter][$(pwd)] svn info"

                            if [ $Debug -gt 0 ]; then
                                echo
                                echo "$Run_Parts_Svn_Info"
                                echo
                            fi
                        fi

                    else

                        Run_Parts_Svn_Info="$Etc_Svn_Info"

                    fi

                    if [ "$Run_Parts_Svn_Info" != "" ]; then

                        if [ $Test_Flag -eq 1 ]; then

                            echo "+ [$Etc_Counter][$(pwd)] svn add"

                            svn add --force .

                            echo "+ [$Etc_Counter][$(pwd)] svn propset"

                            while read Run_Parts_File; do
                                if [ -d "$Run_Parts_File" ]; then
                                    svn propset owner $Cron_User "$Run_Parts_File" &> /dev/null
                                fi
                                svn propset mode 0750 "$Run_Parts_File" &> /dev/null
                                svn propset svn:executable on "$Run_Parts_File" &> /dev/null
                            done <<< "$(find "${Run_Parts_Dir}")"
                        fi

                        if [ "$Etc_Svn_Info" == "" ]; then # do this only if the parent directory svn info is empty (slower)

                            if [ $Perms_Flag -eq 0 ]; then

                                echo "+ [$Etc_Counter][$(pwd)] svn perms"

                                if [ $Test_Flag -eq 1 ]; then
                                    svn perms &> /dev/null
                                fi
                            fi

                            if [ $Commit_Flag -eq 0 ]; then

                                echo "+ [$Etc_Counter][$(pwd)] svn commit"

                                if [ $Test_Flag -eq 1 ]; then
                                    echo
                                    svncommit cron -m "$0 commit"
                                    echo
                                    svn up &> /dev/null
                                fi
                            fi

                        fi

                    fi
                fi


            done <<< "$(grep run-parts "$Cron_D_File" | grep -v ^\#)"
                Run_Parts_Svn_Info=""

            cd "$Cron_D_Dir"

            if [ "$Etc_Svn_Info" != "" ]; then

                if [ $Perms_Flag -eq 0 ]; then

                    echo "+ [$Etc_Counter][$(pwd)] svn perms"

                    if [ $Test_Flag -eq 1 ]; then
                        svn perms &> /dev/null
                    fi
                fi

                if [ $Commit_Flag -eq 0 ]; then

                    echo "+ [$Etc_Counter][$(pwd)] svn commit"

                    if [ $Test_Flag -eq 1 ]; then
                        echo
                        svncommit cron -m "$0 commit"
                        echo
                        svn up &> /dev/null
                    fi
                fi

            fi

        done

        cd "${Etc_Dir}"

        if [ "$Etc_Svn_Info" != "" ]; then

            echo "+ [$Etc_Counter][$(pwd)] svn up"

            if [ $Test_Flag -eq 1 ]; then
                svn up &> /dev/null
            fi

            echo "+ [$Etc_Counter][$(pwd)] svn stat"

            if [ $Test_Flag -eq 1 ]; then
                #echo
                svn stat
                echo
            fi

        fi

    done

    cd "$Here"

    apexFinish $Return_Code


