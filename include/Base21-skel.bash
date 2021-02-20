#!/bin/bash

# This script will ... simplify setting up openvpn clients & servers

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

# begin Base.bash.include

if [ ${#Debug} -gt 0 ]; then
    Debug=${Debug}
else
    if [ ${#DEBUG} -gt 0 ]; then
        Debug=${DEBUG}
    else
        Debug=0
    fi
fi

if [ ${#Base_Bash_Source} -eq 0 ]; then
    Base_Bashes=()
    Base_Bashes+=(Base21.bash)

    Base_Bash_Dirs=()
    Base_Bash_Dirs+=(/base)
    Base_Bash_Dirs+=(/usr)
    Base_Bash_Dirs+=(${BASH_SOURCE%/*})
    Base_Bash_Dirs+=(~)

    for Base_Bash_Dir in ${Base_Bash_Dirs[@]}; do
        while [ ${#Base_Bash_Dir} -gt 0 ] && [ "$Base_Bash_Dir" != "/" ]; do # search backwards
            Base_Bash_Source_Dirs=()
            Base_Bash_Source_Dirs+=("${Base_Bash_Dir}/include/base-bash")
            Base_Bash_Source_Dirs+=("${Base_Bash_Dir}/include")
            Base_Bash_Source_Dirs+=("${Base_Bash_Dir}")
            for Base_Bash in ${Base_Bashes[@]}; do
                for Base_Bash_Source_Dir in ${Base_Bash_Source_Dirs[@]}; do
                    Base_Bash_Source=${Base_Bash_Source_Dir}/${Base_Bash}

                    if [ -r "${Base_Bash_Source}" ]; then
                        source "${Base_Bash_Source}"
                        break
                    else
                        unset -v Base_Bash_Source
                    fi
                done
                [ ${Base_Bash_Source} ] && break
            done
            [ ${Base_Bash_Source} ] && break
            Base_Bash_Dir=${Base_Bash_Dir%/*} # search backwards
        done
        [ ${Base_Bash_Source} ] && break
    done
fi

if [ ${#Base_Bash_Source} -eq 0 ] || [ ! -r "${Base_Bash_Source}" ]; then
    echo "${Base_Bash} file not readable"
    exit 1
fi

# end Base.bash.include

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

# upgrade "$0" "/base/bin /usr/local/bin"

# optionArguments Logic

# add usage help to the Base_Usage array (before usage() is called for the first time [via optionArguments])

Base_Usage+=("-m | --mutiple <value(s)> = supports an argument with one or more <value(s)>")
Base_Usage+=("-n | --multiple-optional [value(s)] = supports an argument with or without one or more [value(s)]")
Base_Usage+=("-o | --one = supports only one argument without a value")
Base_Usage+=("-s | --single <value> = supports only one argument with a single <value>")
Base_Usage+=("-t | --single-optional [value(s)] = supports only one argument with or without a [value]")
Base_Usage+=("") # blank link; seperator
Base_Usage+=("-e | --example <value> = use the given example value")
Base_Usage+=("=more help for the example flag")

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
                baseFinish 2
            fi
            ;;

        esac

        ((Option_Arguments_Index++))
    done
    unset -v Option_Argument_Next Option_Arguments_Index Option_Arguments_Shift

# e.g., if there are no arguments, echo a usage message and/or exit

if [ ${Base_Arguments_Count} -eq 0 ]; then usage; fi
if [ ${Base_Arguments_Count} -eq 1 ] && [ ${Debug_Flag} -ne 1 ]; then usage; fi
if [ ${Base_Arguments_Count} -eq 2 ] && [ ${Debug_Flag} -ne 1 ] && [ "${Debug}" != "" ]; then usage; fi

# Main Logic

baseStart

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

debugValue Base_Source 2

aborting "fail, fail, fail"

echo "$0 finishing ..."

baseFinish ${Return_Code}
