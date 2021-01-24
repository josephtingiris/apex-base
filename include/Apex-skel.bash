#!/bin/bash

# This script will ... provide examples for how to use Apex.bash.

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
        while [ ${#Apex_Bash_Dir} -gt 0 ] && [ "$Apex_Bash_Dir" != "/" ]; do # search backwards
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

# explicit declarations

declare -x Version="0.1";

declare -i Return_Code=0

# functionNames

function exampleFunction() {

    debugFunction $@

    # begin function logic

    local example_arg="$1"
    local example_variable="example variable"

    debugValue example_variable 2

    echo "example_arg=${example_arg}, example_variable=${example_variable}"

    # end function logic

    debugFunction $@

}

# Validation Logic

dependency "date"

# typically, upgrade before optionArguments, begin, etc

# upgrade "$0" "/apex/bin /usr/local/bin"

# optionArguments Logic

# add usage help to the Apex_Usage array (before usage() is called for the first time [via optionArguments])

Apex_Usage+=("-m | --mutiple <value(s)> = supports an argument with one or more <value(s)>")
Apex_Usage+=("-n | --multiple-optional [value(s)] = supports an argument with or without one or more [value(s)]")
Apex_Usage+=("-o | --one = supports only one argument without a value")
Apex_Usage+=("-s | --single <value> = supports only one argument with a single <value>")
Apex_Usage+=("-t | --single-optional [value(s)] = supports only one argument with or without a [value]")
Apex_Usage+=("") # blank link; seperator
Apex_Usage+=("-e | --example <value> = use the given example value")
Apex_Usage+=("=more help for the example flag")

# call the optionArguments function (to process common options, i.e. --debug, --help, --usage, --yes, etc)

optionArguments $@

# expand upon the optionArguments function (careful, same named switches will be processed twice)

# for each cli option (argument), evaluate them case by case, process them, and shift to the next

declare -i Example_Flag=1 # 0=true/on/yes, 1=false/off/no

declare -i Multiple_Flag=1 # default off
declare -i Multiple_Optional_Flag=1 # default off
declare -i One_Flag=1 # default off
declare -i Single_Flag=1 # default off
declare -i Single_Optional_Flag=1 # default off

declare -i Restart_Flag=1 # default off
declare -i Start_Flag=1 # default off
declare -i Status_Flag=1 # default off
declare -i Stop_Flag=1 # default off

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
        -e | --example | -example)
            # supports only one argument with a value
            if [ ${Example_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Example+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Example="$(listUnique "${Example}")"
            if [ "${Example}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Example_Flag=0
            debugValue Example_Flag 2 "${Option_Argument} flag was set [${Example}]"
            ;;

        -m | --m | -multiple | --multiple)
            # supports an argument with one or more value(s)
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Multiple+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Multiple="$(listUnique "${Multiple}")"
            if [ "${Multiple}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Multiple_Flag=0
            debugValue Multiple_Flag 2 "${Option_Argument} flag was set [${Multiple}]"
            ;;

        -n | --n | -multiple-optional | --multiple-optional)
            # supports an argument with or without one or more value(s)
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    declare Multiple_Optional+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Multiple_Optional="$(listUnique "${Multiple_Optional}")"
            Multiple_Optional_Flag=0
            debugValue Multiple_Optional_Flag 2 "${Option_Argument} flag was set [${Multiple_Optional}]"
            ;;

        -o | -one | --one)
            # supports only one argument without a value
            if [ ${One_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    usage "${Option_Argument} argument does not accept values"
                fi
            fi
            One_Flag=0
            debugValue One_Flag 2 "${Option_Argument} flag was set"
            ;;

        -s | --s | -single | --single)
            # supports only one argument with a single value
            if [ ${Single_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" == "-" ] || [ "${Option_Argument_Next}" == "restart" ] || [ "${Option_Argument_Next}" == "start" ] || [ "${Option_Argument_Next}" == "status" ] || [ "${Option_Argument_Next}" == "stop" ]; then
                    usage "${Option_Argument} requires a given value"
                else
                    declare Single+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Single="$(listUnique "${Single}")"
            if [ "${Single}" == "" ]; then
                usage "${Option_Argument} requires a valid value"
            fi
            Single_Flag=0
            debugValue Single_Flag 2 "${Option_Argument} flag was set [${Single}]"
            ;;

        -t | --t | -single-optional | --single-optional)
            # supports only one argument with or without a value
            if [ ${Single_Optional_Flag} -eq 0 ]; then
                usage "${Option_Argument} may only be given once"
            fi
            if [ "${Option_Argument_Next}" != "" ]; then
                if [ "${Option_Argument_Next:0:1}" != "-" ] && [ "${Option_Argument_Next}" != "restart" ] && [ "${Option_Argument_Next}" != "start" ] && [ "${Option_Argument_Next}" != "status" ] && [ "${Option_Argument_Next}" != "stop" ]; then
                    declare Single_Optional+=" ${Option_Argument_Next}"
                    Option_Arguments_Shift=1
                fi
            fi
            Single_Optional="$(listUnique "${Single_Optional}")"
            Single_Optional_Flag=0
            debugValue Single_Optional_Flag 2 "${Option_Argument} flag was set [${Single_Optional}]"
            ;;

        restart)
            # supports 'restart' argument
            Restart_Flag=0
            ((Option_Arguments_Index++))
            debugValue Restart_Flag 2 "${Option_Argument} flag was set"
            ;;

        start)
            # supports 'start' argument
            Start_Flag=0
            debugValue Start_Flag 2 "${Option_Argument} flag was set"
            ;;

        status)
            # supports 'status' argument
            Status_Flag=0
            debugValue Status_Flag 2 "${Option_Argument} flag was set"
            ;;

        stop)
            # supports 'stop' argument
            Stop_Flag=0
            debugValue Stop_Flag 2 "${Option_Argument} flag was set"
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
    unset -v Option_Argument_Next Option_Arguments_Index Option_Arguments_Shift

# e.g., if there are no arguments, echo a usage message and/or exit

if [ ${Apex_Arguments_Count} -eq 0 ]; then usage; fi
if [ ${Apex_Arguments_Count} -eq 1 ] && [ ${Debug_Flag} -ne 1 ]; then usage; fi
if [ ${Apex_Arguments_Count} -eq 2 ] && [ ${Debug_Flag} -ne 1 ] && [ "${Debug}" != "" ]; then usage; fi

# Main Logic

apexStart

echo "$0 starting ..."

if [ ${Multiple_Flag} -eq 0 ]; then
    echo "Multiple = ${Multiple}"
fi

if [ ${Multiple_Optional_Flag} -eq 0 ]; then
    echo "Multiple_Optional = ${Multiple_Optional}"
fi

if [ ${One_Flag} -eq 0 ]; then
    echo "One = ${One}"
fi

if [ ${Single_Flag} -eq 0 ]; then
    echo "Single = ${Single}"
fi

if [ ${Single_Optional_Flag} -eq 0 ]; then
    echo "Single_Optional = ${Single_Optional}"
fi

if [ ${Restart_Flag} -eq 0 ]; then
    Start_Flag=0
    Stop_Flag=0
fi

if [ ${Start_Flag} -eq 0 ]; then
    question "Are you ready to leave"
    if [ "${Question_Flag}" -eq 0 ]; then
        echo "goodbye!"
    else
        echo "let's continue!"
    fi

    debugValue "Example" 1 "this is an example"

    if [ ${Example_Flag} -eq 0 ]; then
        exampleFunction "${Example}"
    fi
fi

debug "debug() 0 is always displayed" 0
debug "debug() 1 is not always displayed" 1

debugValue Apex_Source 2

aborting "fail, fail, fail"

echo "$0 finishing ..."

apexFinish ${Return_Code}
