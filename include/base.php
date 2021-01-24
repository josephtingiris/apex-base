<?php

# This is a php include (source) file; full of functions and other useful stuff
#
# 20150803, joseph.tingiris@gmail.com

# For coding conventions, organization, standards, & references, see: $BASE_DIR/README

# GLOBAL_VARIABLES

# be careful changing the order of these

$BASE_INCLUDE=__FILE__;

if (empty($BASE_DIR)) {
    $BASE_DIRS=array("/base","/mux");
    foreach ($BASE_DIRS as $BASE_DIR) {
        if (is_dir($BASE_DIR)) break;
    }
    if (empty($BASE_DIR)) $BASE_DIR="/base";
}

if (empty($DEBUG)) $DEBUG=0;

if (empty($DEBUG_FLAG)) $DEBUG_FLAG=0;

$PATH="$BASE_DIR/bin:$BASE_DIR/sbin:/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin"; $_SERVER["PATH"]=$PATH;

if (empty($UNIQ)) $UNIQ=date("Ymd")."-".Uuid();

if (empty($USER) && !empty($_SERVER["USER"])) $USER=$_SERVER["USER"];

if (empty($USER) && Mod_Php()) $USER="apache";

if (empty($USER)) $USER="nobody";

(!empty($_SERVER["argv"])) ? $ARGUMENTS=$_SERVER["argv"] : $ARGUMENTS=array();

(!empty($_SERVER["argc"])) ? $ARGUMENTS_TOTAL=(int)$_SERVER["argc"]-1 : $ARGUMENTS_TOTAL=0;

(empty($BASE_0)) ? (!empty($ARGUMENTS[0]) ? $BASE_0=$ARGUMENTS[0] : $BASE_0="") : false;

if (empty($BASE_DIR_ACCOUNT)) {
    $BASE_DIR_ACCOUNT="$BASE_DIR/account";
    if (!is_dir($BASE_DIR_ACCOUNT)) {
        if (!mkdir($BASE_DIR_ACCOUNT,0750,true)) {
            Aborting("failed to create account directory $BASE_DIR_ACCOUNT",3);
        }
    }
}

if (empty($BASE_ACCOUNT)) {
    $BASE_ACCOUNT="";
    if(stristr(getcwd(),$BASE_DIR."/account/")) list($_,$__,$___,$BASE_ACCOUNT)=explode("/",getcwd());
    if (!is_dir("$BASE_DIR_ACCOUNT/$BASE_ACCOUNT")) {
        $BASE_ACCOUNT="";
    }
}

if (empty($BASE_ARG)) $BASE_ARG=$ARGUMENTS;

if (empty($BASE_BACKUP)) $BASE_BACKUP="/backup";

(empty($BASE_DIR_0)) ? (!empty($_SERVER["PHP_SELF"]) ? $BASE_DIR_0=dirname($_SERVER["PHP_SELF"]) : $BASE_DIR_0=dirname($BASE_0)) : null;

if (empty($BASE_COMPANY)) {
    if (is_readable($BASE_DIR."/etc/company_name")) {
        $BASE_COMPANY=trim(file_get_contents($BASE_DIR."/etc/company_name",NULL,NULL,0,256));
    }
    if (empty($BASE_COMPANY)) $BASE_COMPANY="No Company Name";
}

if (empty($BASE_DATACENTERS)) $BASE_DATACENTERS=array("atl","dal","lon","man");

if (empty($BASE_DOMAIN)) {
    if (is_readable($BASE_DIR."/etc/domain_name")) {
        $BASE_DOMAIN=trim(file_get_contents($BASE_DIR."/etc/domain_name",NULL,NULL,0,256));
    }
    if (empty($BASE_DOMAIN)) $BASE_DOMAIN="localdomain";
}

if (empty($BASE_ENVIRONMENTS)) $BASE_ENVIRONMENTS=array("dev","qa","test","prod");

(empty($BASE_NAME)) ? (!empty($_SERVER["PHP_SELF"]) ? $BASE_NAME=basename($_SERVER["PHP_SELF"]) : $BASE_NAME=basename($BASE_0)) : null;

if (empty($BASE_PID)) $BASE_PID=getmypid();

if (empty($BASE_TOP)) $BASE_TOP="$BASE_DIR";

if (empty($HERE)) $HERE=getcwd();

if (empty($HOSTNAME)) $HOSTNAME=gethostname();

if (empty($LOGFILE)) $LOGFILE="/tmp/".$BASE_NAME.".log";

if (empty($LOCKFILE)) $LOCKFILE="/tmp/".$BASE_NAME.".lock";

if (empty($LOCKFILE_FLAG)) $LOCKFILE_FLAG=0;

(!empty($_SERVER["LOGNAME"])) ? $LOGNAME=$_SERVER["LOGNAME"] : $LOGNAME="$USER";

if (empty($MACHINE_CLASS)) $MACHINE_CLASS=preg_replace("/[0-9]/","",$HOSTNAME);

if (empty($MACHINE_NAME)) $MACHINE_NAME=$HOSTNAME;

if (empty($MACHINE_DIR)) $MACHINE_DIR=$BASE_DIR."/machine/";

if (empty($OPTION)) $OPTION=0;

if (empty($OPTIONS)) $OPTIONS=array(array("debug","[=level] print debug messages (less than) [level]",true),array("help","print this message",true),array("version","print version",true));

(!empty($_SERVER["PWD"])) ? $PWD=$_SERVER["PWD"] : $PWD=$HERE;

if (empty($QUESTION_FLAG)) $QUESTION_FLAG=0;

if (empty($SSH)) $SSH=Which("ssh");

if (empty($STEP)) $STEP=0;

if (empty($SVN)) $SVN=Which("svn");

if (empty($SVN_DIR)) $SVN_DIR="/var/svn";

if (empty($SVN_SERVE)) $SVN_SERVE=Which("svnserve");

if (empty($SVN_TOP)) $SVN_TOP=$SVN_DIR;

if (empty($SVN_TRUNK)) $SVN_TRUNK="svn+ssh://svn.$BASE_DOMAIN/repo$BASE_DIR/trunk";

if (empty($TIME_START)) $TIME_START=microtime(true);

if (empty($TMPFILE)) $TMPFILE="/tmp/".$BASE_NAME.".".$UNIQ.".tmp";

if (empty($VERBOSE_FLAG)) $VERBOSE_FLAG=0;

if (empty($VERSION)) $VERSION="0";

if (empty($WHOM)) $WHOM=exec(Which("who")." -m");

if (empty($WHO)) list($WHO)=explode(" ",$WHOM);

if (empty($WHO)) $WHO=$USER;

if (empty($WHO)) $WHO=$LOGNAME;

if (empty($WHO_IP) && strpos($WHOM,"(") !== FALSE && strpos($WHOM,")") !== FALSE) $WHO_IP=trim(trim(substr($WHOM,strpos($WHOM,"("))),"()");

if (empty($WHO_IP)) if (!empty($_SERVER["SSH_CLIENT"])) list($WHO_IP)=explode(" ",$_SERVER["SSH_CLIENT"]);

if (empty($WHO_IP)) $WHO_IP="0.0.0.0";

if (empty($YES_FLAG)) $YES_FLAG=0;

# Functions

if (!function_exists('_Prototype_Function')) {
function _Prototype_Function() {
    # begin function logic

    echo "Hello World!".Br();

    # end function logic
}
}

if (!function_exists('Aborting')) {
function Aborting($aborting_message=null, $return_code=1, $alert=false) {
    # begin function logic

    $aborting_message="aborting, $aborting_message ... ($return_code)";
    $aborting_message=Timestamp($aborting_message);

    echo Br();
    echo "$aborting_message".Br();;
    echo Br();

    #System_Log("$aborting_message");

    if ($alert) {
        if (function_exists('Alert_Mail')) {
            Require_Include("require-alert.php");
        }
    }

    if (function_exists('Alert_Mail')) {
        if ($alert) {
            global $alert_to, $alert_from, $alert_cc;
            Alert_Mail($subject="!! ABORT !! on ".gethostname(), $body=$aborting_message."\r\n\r\n", $alert_to, $alert_from, $alert_cc);
        }
    }

    Stop($return_code);

    # end function logic
}
}

if (!function_exists('Backup_Files')) {
function Backup_Files($backup_files=null,$backup_files_directory=null) {
    # begin function logic
    # end function logic
}
}

if (!function_exists('Backup_Files1')) {
function Backup_Files1($backup_files=null,$backup_files_directory=null) {
    # begin function logic
    if (empty($backup_files)) return;
    if (is_object($backup_files)) return;
    if (is_string($backup_files)) $backup_files_array=explode(" ",$backup_files);
    if (is_array($backup_files)) $backup_files_array=$backup_files;

    if ($backup_files_directory == null) {
        if(empty($GLOBALS["BASE_BACKUP"])) {
            Aborting("backup_files_directory is null",3);
        } else {
            $backup_files_directory=$GLOBALS["BASE_BACKUP"];
        }
    }

    if (!file_exists($backup_files_directory)) {
        if (mkdir($backup_files_directory,0700,true)) {
            Debug("created backup files directory $backup_files_directory",3);
        } else {
            Aborting("failed to create backup files directory $backup_files_directory",3);
        }
    } else {
        if (!is_dir($backup_files_directory)) {
            Aborting("$backup_files_directory exists but is not a directory",3);
        } else {
            if (!is_writable($backup_files_directory)) {
                Aborting("$backup_files_directory exists and is a directory but is not writable",2);
            }
        }
    }

    Debug_Variable("backup_files_directory",3,$backup_files_directory);

    foreach($backup_files_array as $backup_file) {
        Debug_Variable("backup_file",3,$backup_file);
        if (is_dir($backup_file)) {
            Warning("Backup_Files does NOT backup directories (yet), skipping $backup_file");
            if (!file_exists($backup_files_directory."/".$backup_file)) {
                if (mkdir($backup_files_directory."/".$backup_file,0700,true)) {
                    Debug("created backup files directory $backup_files_directory/$backup_file",3);
                } else {
                    # mkdir failed, so just warn and continue
                    Warning("failed to mkdir $backup_files_directory/$backup_file, skipping");
                    continue;
                }
            }
            foreach (Find($backup_file,"") as $backup_files_array_add) {
                    echo "adding $backup_files_array_add to backup_files_array\n";
                    $backup_files_array[]=$backup_files_array_add;
            }
            continue;
        }
        $backup_file_basename=basename($backup_file);
        $backup_file_dirname=dirname($backup_file);
        Debug_Variable("backup_file_basename",3,$backup_file_basename);
        Debug_Variable("backup_file_dirname",3,$backup_file_dirname);

        $backup_file_last=Find($backup_files_directory,"$backup_file_basename\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.[0-9]*$");
        sort($backup_file_last,SORT_NATURAL);
         $backup_file_last=end($backup_file_last);
        Debug_Variable("backup_file_last",3,$backup_file_last);

        $backup_file_counter=0;
        $backup_file_name=null;
        while(file_exists($backup_file_name) || $backup_file_name == null) {
            $backup_file_counter++;
            $backup_file_name=$backup_files_directory."/".$backup_file_basename.".".date("Ymd").".".$backup_file_counter;
        }
        Debug_Variable("backup_file_name",3,$backup_file_name);

        $backup_copy=false;
        if ($backup_file_last == null) {
            $backup_copy=true;
        } else {
            if (!Diff($backup_file,$backup_file_last)) {
                continue;
            } else {
                $backup_copy=true;
            }
        }

        if ($backup_copy) {
            if (copy($backup_file,$backup_file_name)) {
                echo "created backup $backup_file_name".Br();
            } else {
                Aborting("failed to create backup $backup_file_name",4);
            }
        }
    }
    # end function logic
}
}

if (!function_exists('Br')) {
function Br() { # begin function logic
    if (Mod_Php()) {
        $br="<br>\n"; #echo "this is being run via apache";
    } else {
        $br="\n"; #echo "this is being run via cla";
    } # end function logic
    return $br;
}
}

if (!function_exists('Debug_Array')) {
function Debug_Array($debug_array,$debug_level=99,$array_name="") { # begin function logic
    if(!is_array($debug_array) and !is_object($debug_array)) return;
    if (empty($GLOBALS["DEBUG"])) $GLOBALS["DEBUG"]=(int)0;
    if ($GLOBALS["DEBUG"] >= $debug_level) {
        $debug_message="Debug_Array=$array_name".Br();
        $debug_message.=print_r($debug_array,true);
        Debug($debug_message,$debug_level);
    }    # end function logic
}
}

if (!function_exists('Debug')) {
function Debug($debug_message, $debug_level=0, $debug_function_name=null) {
    if ($debug_message == null) $debug_message="unknown";
    if (empty($GLOBALS["DEBUG"])) $GLOBALS["DEBUG"]=(int)0;
    (empty($GLOBALS["DEBUG_ERROR_LOG"])) ? $debug_error_log=false : $debug_error_log=true;
    if ($GLOBALS["DEBUG"] >= $debug_level) {
        $debug_output=1;
    } else {
        $debug_output=0;
    }

    # always output debug level 0
    if ($debug_level == null || $debug_level == 0) {
        $debug_output=1;
    }

    if ($debug_output != 1) {
        return;
    } else {
        if (empty($GLOBALS["MACHINE_NAME"])) $GLOBALS["MACHINE_NAME"]=gethostname();

        $color_terms=array("ansi","xterm", "xterm-256color");
        $debug_identifier_minimum_width="            ";
        $debug_funcname_minimum_width="                                 ";
        $machine_name_minimum_width="            ";
        $step_minimum_width="   ";

        if ($debug_function_name == null && !empty($GLOBALS["DEBUG_FUNCTION_NAME"])) {
            $debug_function_name=$GLOBALS["DEBUG_FUNCTION_NAME"];
        } else {
            # automatically determine the caller
            $backtraces=debug_backtrace();
            foreach($backtraces as $backtrace) {
                if (empty($backtrace['function'])) continue;
                $backtrace_file=null;
                $backtrace_line=null;
                $backtrace_function=null;
                if (!empty($backtrace['file'])) $backtrace_file=basename($backtrace['file']).":";
                if (!empty($backtrace['line'])) $backtrace_line=$backtrace['line'].":";
                if (!empty($backtrace['function'])) $backtrace_function=$backtrace['function'];
                if ($backtrace_function == null) continue;
                #if (strpos($backtrace_function,'Debug') !== false) continue;
                #print_r($backtrace);
                $debug_function_name=basename($backtrace_file).$backtrace_line.$backtrace_function;
                #echo "backtrace_function=$backtrace_function".Br();
            }
            #print_r(debug_backtrace());
            if ($debug_function_name == null) $debug_function_name="main";
        }

        if (Mod_Php()) {
            $debug_color=true;
        } else {
            $term=getenv("TERM");
            foreach($color_terms as $color_term) {
                if ($term == $color_term) {
                    $debug_color=true;
                    break;
                } else {
                    $debug_color=false;
                }
            }
        }

        # ansi color codes
        $ansi_reset = "\33[0;0m";

        $ansi_bold = "\33[1m";
        $ansi_bold_off = "\33[22m";

        $ansi_black = $ansi_bold_off."\33[30m";
        $ansi_boldblack = $ansi_bold."\33[30m";
        $ansi_background_black = $ansi_bold_off."\33[40m";
        $ansi_background_boldblack = $ansi_bold."\33[40m";

        $ansi_red = $ansi_bold_off."\33[31m";
        $ansi_boldred = $ansi_bold."\33[31m";
        $ansi_background_red = $ansi_bold_off."\33[31m";
        $ansi_background_boldred = $ansi_bold."\33[31m";

        $ansi_green = $ansi_bold_off."\33[32m";
        $ansi_boldgreen = $ansi_bold."\33[32m";
        $ansi_background_green = $ansi_bold_off."\33[42m";
        $ansi_background_boldgreen = $ansi_bold."\33[42m";

        $ansi_yellow = $ansi_bold_off."\33[33m";
        $ansi_boldyellow = $ansi_bold."\33[33m";
        $ansi_background_yellow = $ansi_bold_off."\33[43m";
        $ansi_background_boldyellow = $ansi_bold."\33[43m";

        $ansi_blue = $ansi_bold_off."\33[34m";
        $ansi_boldblue = $ansi_bold."\33[34m";
        $ansi_background_blue = $ansi_bold_off."\33[44m";
        $ansi_background_boldblue = $ansi_bold."\33[44m";

        $ansi_magenta = $ansi_bold_off."\33[35m";
        $ansi_boldmagenta = $ansi_bold."\33[35m";
        $ansi_background_magenta = $ansi_bold_off."\33[45m";
        $ansi_background_boldmagenta = $ansi_bold."\33[45m";

        $ansi_cyan = $ansi_bold_off."\33[36m";
        $ansi_boldcyan = $ansi_bold."\33[36m";
        $ansi_background_cyan = $ansi_bold_off."\33[46m";
        $ansi_background_boldcyan = $ansi_bold."\33[46m";

        $ansi_white = "\33[37m";
        $ansi_boldwhite = $ansi_bold."\33[37m";
        $ansi_background_white = $ansi_bold_off."\33[47m";
        $ansi_background_boldwhite = $ansi_bold."\33[47m";

        $ansi_default = "\33[37m";
        $ansi_bolddefault = $ansi_bold."\33[37m";
        $ansi_background_default = $ansi_bold_off."\33[47m";
        $ansi_boldbackground_bolddefault = $ansi_bold."\33[47m";


        # html color names (need to finish)
        $html_reset = "</font>";

        $html_bold = "<b>";
        $html_bold_off = "</b>";

        $html_black = "<font color=\"Black\">";
        $html_boldblack = "<font color=\"Black\">";
        $html_background_black = "<font color=\"Black\">";
        $html_background_boldblack = "<font color=\"Black\">";

        $html_red = "<font color=\"Red\">";
        $html_boldred = "<font color=\"Red\">";
        $html_background_red = "<font color=\"Red\">";
        $html_background_boldred = "<font color=\"Red\">";

        $html_green = "<font color=\"Green\">";
        $html_boldgreen = "<font color=\"Green\">";
        $html_background_green = "<font color=\"Green\">";
        $html_background_boldgreen = "<font color=\"Green\">";

        $html_yellow = "<font color=\"Yellow\">";
        $html_boldyellow = "<font color=\"Yellow\">";
        $html_background_yellow = "<font color=\"Yellow\">";
        $html_background_boldyellow = "<font color=\"Yellow\">";

        $html_blue = "<font color=\"Blue\">";
        $html_boldblue = "<font color=\"Blue\">";
        $html_background_blue = "<font color=\"Blue\">";
        $html_background_boldblue = "<font color=\"Blue\">";

        $html_magenta = "<font color=\"Purple\">";
        $html_boldmagenta = "<font color=\"Purple\">";
        $html_background_magenta = "<font color=\"Purple\">";
        $html_background_boldmagenta = "<font color=\"Purple\">";

        $html_cyan = "<font color=\"Aqua\">";
        $html_boldcyan = "<font color=\"Aqua\">";
        $html_background_cyan = "<font color=\"Aqua\">";
        $html_background_boldcyan = "<font color=\"Aqua\">";

        $html_white = "<font color=\"White\">";
        $html_boldwhite = "<font color=\"White\">";
        $html_background_white = "<font color=\"White\">";
        $html_background_boldwhite = "<font color=\"White\">";

        $html_default = "<font color=\"Black\">";
        $html_bolddefault = "<font color=\"Black\">";
        $html_background_default = "<font color=\"Black\">";


        # uses standard HTML5 color names & previosly defined ansi color names
        if (Mod_Php()) {
            $color_0=$html_black;
            $color_1=$html_boldblack;
            $color_2=$html_green;
            $color_3=$html_boldgreen;
            $color_4=$html_cyan;
            $color_5=$html_boldcyan;
            $color_6=$html_blue;
            $color_7=$html_boldblue;
            $color_8=$html_magenta;
            $color_9=$html_boldmagenta;
            $color_10=$html_red;
            $color_100=$html_boldred;
            $color_1000=$html_boldblue;
            $color_reset=$html_reset;
        } else {
            $color_0=$ansi_white;
            $color_1=$ansi_boldwhite;
            $color_2=$ansi_green;
            $color_3=$ansi_boldgreen;
            $color_4=$ansi_cyan;
            $color_5=$ansi_boldcyan;
            $color_6=$ansi_blue;
            $color_7=$ansi_boldblue;
            $color_8=$ansi_magenta;
            $color_9=$ansi_boldmagenta;
            $color_10=$ansi_red;
            $color_100=$ansi_background_white.$ansi_boldred;
            $color_1000=$ansi_boldyellow;
            $color_reset=$ansi_reset;
        }

        $debug_echo="";
        if ($debug_color && !$debug_error_log) {
            if ($debug_level == 0) $debug_echo=$color_0;
            if ($debug_level == 1) $debug_echo=$color_1;
            if ($debug_level == 2) $debug_echo=$color_2;
            if ($debug_level == 3) $debug_echo=$color_3;
            if ($debug_level == 4) $debug_echo=$color_4;
            if ($debug_level == 5) $debug_echo=$color_5;
            if ($debug_level == 6) $debug_echo=$color_6;
            if ($debug_level == 7) $debug_echo=$color_7;
            if ($debug_level == 8) $debug_echo=$color_8;
            if ($debug_level == 9) $debug_echo=$color_9;
            if ($debug_level >= 10 && $debug_level < 100) $debug_echo=$color_10;
            if ($debug_level >= 100 && $debug_level < 999) $debug_echo=$color_100;
            if ($debug_level >= 1000) $debug_echo=$color_1000;
        }

        $debug_identifier=str_pad("DEBUG [$debug_level]",12);

        if (!empty($GLOBALS["UUID"])) {
            $debug_identifier="[".$GLOBALS["UUID"]."] ".$debug_identifier;
        }

        $debug_identifier=Timestamp($debug_identifier);

        if ($debug_function_name != null && $GLOBALS["DEBUG"] >= 3) {
            $debug_echo.=str_pad($debug_identifier,strlen($debug_identifier_minimum_width))." : ".str_pad($GLOBALS["MACHINE_NAME"],strlen($machine_name_minimum_width))." : ".str_pad($debug_function_name."()",strlen($debug_funcname_minimum_width))." : ".$debug_message;
        } else {
            $debug_echo.=str_pad($debug_identifier,strlen($debug_identifier_minimum_width))." : ".str_pad($GLOBALS["MACHINE_NAME"],strlen($machine_name_minimum_width))." : ".$debug_message;
        }

        if ($debug_color && !$debug_error_log) {
            $debug_echo.=$color_reset;
        }

        $debug_echo.=Br();

        if ($debug_error_log && Mod_Php()) {
            error_log(trim(strip_tags($debug_echo)));
        } else echo $debug_echo;
    }
}
}

if (!function_exists('Debug_Function')) {
function Debug_Function($arguments) {
    #print_r(debug_backtrace());
}
}

if (!function_exists('Debug_Variable')) {
function Debug_Variable($variable_name, $debug_level=9, $variable_comment=null) {
    # begin function logic

    $global_variable=true;

    $debug_message=str_pad($variable_name,30)." = ";
    if (!empty($GLOBALS[$variable_name])) {
        if (is_array($GLOBALS[$variable_name]) || is_object($GLOBALS[$variable_name])) {
            $debug_message.=print_r($GLOBALS[$variable_name],true);
        } else {
            if ($GLOBALS[$variable_name] == null) {
                $debug_message.="NULL";
            } else $debug_message.=$GLOBALS[$variable_name];
        }
    } else {
        $global_variable=false;
    }
    if ($variable_comment != null) {
        if (is_array($variable_comment) || is_object($variable_comment)) {
            $debug_message .= print_r($variable_comment,true);
        } else {
            if ($global_variable) $debug_message .=" (";
            $debug_message.=$variable_comment;
            if ($global_variable) $debug_message .=")";
        }
    }
    Debug(trim($debug_message),$debug_level);

    # end function logic
}
}

if (!function_exists('Diff')) {
function Diff($one=null,$two=null) {
    # begin function logic

    if ($one == null && $two == null) return false;
    if ($one == null && $two != null) return true;
    if ($one != null && $two == null) return true;

    Debug("Diff($one,$two)",33);

    if (is_array($one) && !is_array($two)) return true;
    if (!is_array($one) && is_array($two)) return true;

    if (is_array($one) && is_array($two)) {
        $array_diff=array_diff($one,$two);
        if (empty($array_diff)) {
            return false;
        } else {
            return true;
        }
    }

    $md5_one=null;
    $md5_two=null;

    if (is_readable($one)) {
        $md5_one=md5_file($one);
    } else $md5_one=md5($one);

    if (is_readable($two)) {
        $md5_two=md5_file($two);
    } else $md5_one=md5($one);

    if ($md5_one == $md5_two) {
        # the hashes are identical
        return false;
    } else {
        # the hashes differ
        return true;
    }

    # end function logic
}

#function debug_echo($debug_message, $debug_level=0,$debug_function_name=null) { Debug($debug_message,$debug_level,$debug_function_name); }
#function debugecho($debug_message, $debug_level=0,$debug_function_name=null) { Debug($debug_message,$debug_level,$debug_function_name); }
#
function Find($search_directory=null,$search_pattern=null,$search_pattern_append=null,$search_recursion=true) {
    # begin function logic

    if (!is_dir($search_directory)) {
            Debug("invalid directory $search_directory",5);
            return array();
    }

    $return_result=array();

    if ($search_pattern == "*") $search_pattern=null;

    $search_separators=array("/","@",":","+","!");
    $valid_separator=false;
    foreach ($search_separators as $search_separator) {
        if (strpos($search_pattern,$search_separator) === false) {
            $valid_separator=true;
        } else continue;
        if ($valid_separator) break;
    }
    if ($search_separator == null) {
        Warning("couldn't determine a valid search separator for $search_pattern");
        return;
    }
    $search_pattern=$search_separator.$search_pattern.$search_separator;
    if ($search_pattern_append != null) $search_pattern.=$search_pattern_append;

    Debug_Variable("search_directory",5,$search_directory);
    Debug_Variable("search_pattern",5,$search_pattern);

    $search=array($search_directory);
    while (null !== ($dir = array_pop($search))) {
        if ($dh = opendir($dir)) {
            while (false !== ($file = readdir($dh))) {
                if($file == '.' || $file == '..') continue; # skip these, altogether
                $path = $dir . '/' . $file;
                Debug_Variable("path",599,$path);

                if (is_dir($path)) {
                    # recursion; add the new directory to the array
                    if ($search_recursion) $search[]=$path;
                }

                if (preg_match($search_pattern,$path)) {
                    $return_result[]=$path;
                    Debug("Find found $path",499);
                }
            }
        } else {
            # failed to open directory
            Warning("permissions? could not open directory $dir");
        }

         closedir($dh);
    }

    return $return_result;
    # end function logic
}
}


function Log_Entry_From_Global($log_message, $what="")# $log_file="/tmp/global.log") {
   {
    # begin function logic
    global $logfile;/*
    if (!empty($GLOBALS["logfile"])) $log_file=$GLOBALS["logfile"];
    if (!empty($GLOBALS["log_file"])) $log_file=$GLOBALS["log_file"];
    if (!empty($GLOBALS["LOGFILE"])) $log_file=$GLOBALS["LOGFILE"];
    if (!empty($GLOBALS["LOG_FILE"])) $log_file=$GLOBALS["LOG_FILE"];
    */
    Log_Entry($log_message,$logfile);
    # end function logic
}

function Log_Entry($log_message,$log_file=null) {
    # begin function logic
    if (empty($log_file)) {
        if (!empty($GLOBALS["logfile"])) $log_file=$GLOBALS["logfile"];
        if (!empty($GLOBALS["log_file"])) $log_file=$GLOBALS["log_file"];
        if (!empty($GLOBALS["LOGFILE"])) $log_file=$GLOBALS["LOGFILE"];
        if (!empty($GLOBALS["LOG_FILE"])) $log_file=$GLOBALS["LOG_FILE"];
    }
    if (empty($log_file)) $log_file="/tmp/entry.log";

    if (!empty($GLOBALS["UUID"])) {
        $log_message="[".$GLOBALS["UUID"]."] $log_message";
    }

    $fp=fopen($log_file,"a+");
    if($fp) {
        fwrite($fp,Timestamp($log_message)."\n");
        fclose($fp);
    } else {
        Aborting("ERROR opening $log_file",1);
    }
    # end function logic
}

function Log_Error($log_message,$log_file=null) {
    Log_Entry("ERROR    ".$log_message,$log_file);
}

function Log_Notice($log_message,$log_file=null) {
    Log_Entry("NOTICE   ".$log_message,$log_file);
}

function Log_Warning($log_message,$log_file=null) {
    Log_Entry("WARNING  ".$log_message,$log_file);
}

function Mod_Php() {
    if (!empty($_SERVER["SERVER_NAME"])) {
        return true;
    }
    return false;
}

function Start() {
    # begin function logic

    if (empty($TIME_START)) $TIME_START=microtime(true);

    $debug_message = __FILE__." started";
    Debug($debug_message,101);

    Debug_Variable("BASE_0",101);
    Debug_Variable("BASE_ACCOUNT",101);
    Debug_Variable("BASE_ARG",101);
    Debug_Variable("BASE_BACKUP",101);
    Debug_Variable("BASE_DATACENTER",101);
    Debug_Variable("BASE_DATACENTERS",101);
    Debug_Variable("BASE_DIR",101);
    Debug_Variable("BASE_DIR_0",101);
    Debug_Variable("BASE_DIR_ACCOUNT",101);
    Debug_Variable("BASE_ENVIRONMENT",101);
    Debug_Variable("BASE_ENVIRONMENTS",101);
    Debug_Variable("BASE_INCLUDE",101);
    Debug_Variable("BASE_NAME",101);
    Debug_Variable("BASE_PID",101);
    Debug_Variable("DATACENTER",101);
    Debug_Variable("DEBUG",101);
    Debug_Variable("ENVIRONMENT",101);
    Debug_Variable("HERE",101);
    Debug_Variable("LOCKFILE",101);
    Debug_Variable("LOGFILE",101);
    Debug_Variable("LOGNAME",101);
    Debug_Variable("MACHINE_CLASS",101);
    Debug_Variable("MACHINE_DIR",101);
    Debug_Variable("MACHINE_ENVIRONMENT",101);
    Debug_Variable("MACHINE_NAME",101);
    Debug_Variable("PATH",101);
    Debug_Variable("PWD",101);
    Debug_Variable("SSH",101);
    Debug_Variable("SVN",101);
    Debug_Variable("SVN_SERVE",101);
    Debug_Variable("SVN_TOP",101);
    Debug_Variable("SVN_TRUNK",101);
    Debug_Variable("TIME_START",101);
    Debug_Variable("TMPFILE",101);
    Debug_Variable("UNIQ",101);
    Debug_Variable("USER",101);
    Debug_Variable("VERSION",101);
    Debug_Variable("WHO",101);
    Debug_Variable("WHOM",101);
    Debug_Variable("WHO_IP",101);

    if (is_readable($GLOBALS["LOCKFILE"]) && $GLOBALS["LOCKFILE_FLAG"] > 0) {
        Aborting($GLOBALS["LOCKFILE"]." exists",30);
    }

    if ($GLOBALS["LOCKFILE_FLAG"] > 0 ) touch($GLOBALS["LOCKFILE"]);

    # end function logic
}

function Question($question_message) {
    # begin function logic
    if (!empty($GLOBALS["YES_FLAG"]) && $GLOBALS["YES_FLAG"] == 1) return true;

    if (!empty($GLOBALS["MACHINE_NAME"])) $question_message=$GLOBALS["MACHINE_NAME"]." : ".$question_message;
    if (empty($GLOBALS["YES_FLAG"])) $GLOBALS["YES_FLAG"]=0;

    $question_answer=false;
    if (Mod_Php()) {
        # pop-up?
        return $question_answer;
    } else {
        #exec(Which("stty")." -icanon");
        echo $question_message." [y/n/q] ? ";
        $fd = fopen("php://stdin", "r");
        $question_response = fread($fd,1);
        $question_response=trim($question_response);
        fclose($fd);
        if (strtolower($question_response) == "q") Aborting("quit",1);
        if (strtolower($question_response) == "y") $question_answer=true;
        #exec(Which("stty")." sane");
    }
    return $question_answer;
    # end function logic
}

function Step($step_message) {
    # begin function logic
    if ($step_message == null) return;

    if (empty($GLOBALS["STEP"])) $GLOBALS["STEP"]=(int)0;

    $GLOBALS["STEP"]++;

    $step_message=str_pad("step ".$GLOBALS["STEP"],8)." : ".$step_message;
    $step_message=Timestamp($step_message);

    echo $step_message.Br();

    # end function logic
}

function Step_Verbose($step_message) {
    # begin function logic
    if ($step_message == null) return;

    if (empty($GLOBALS["VERBOSE_FLAG"])) $GLOBALS["VERBOSE_FLAG"]=(int)0;

    if ($GLOBALS["VERBOSE_FLAG"] > 0) {
        Step($step_message);
    }
    # end function logic
}

function Stop($return_code=0) {
    # begin function logic

    if (!empty($GLOBALS["STEP"])) $GLOBALS["STEP"]=(int)0;

    if (!empty($GLOBALS["LOCKFILE_FLAG"]) && $GLOBALS["LOCKFILE_FLAG"] <= 0) {
        if (!empty($GLOBALS["LOCKFILE"]) && is_writable($GLOBALS["LOCKFILE"])) unlink($GLOBALS["LOCKFILE"]);
    }

    if (!empty($GLOBALS["TMPFILE"]) && is_writable($GLOBALS["TMPFILE"])) unlink($GLOBALS["TMPFILE"]);

    if (!empty($GLOBALS["HERE"]) && is_dir($GLOBALS["HERE"])) chdir($GLOBALS["HERE"]);

    $debug_message = __FILE__." finished";

    if (!empty($GLOBALS["TIME_START"])) {
        $time_stop=microtime(true);
        $time_total=$time_stop-$GLOBALS["TIME_START"];
        $debug_message .= " in ".$time_total." seconds";
    }

    Debug($debug_message,101);

    # end function logic

    exit($return_code);
}

function System_Log($log_message=null) {
    # begin function logic
    global $BASE_NAME,$USER,$PWD,$WHO_IP;

    if ($log_message == null) return;
    exec(Which("logger")." -t $BASE_NAME \"$WHO_IP : $USER : $PWD : $log_message\"");
    # end function logic
}

function Timestamp($timestamp_message=null,$timestamp_force=true) {
    # begin function logic
    if ($timestamp_force) {
        if ($timestamp_message != null && $timestamp_message != "") {
            $timestamp_message=date("Y-m-d H:i:s")." : ".$timestamp_message;
        } else {
            $timestamp_message=date("Y-m-d H:i:s");
        }
    }
    # end function logic

    return $timestamp_message;
}

function Options_Character($options=array(),$long_option=null) {
    if ($long_option == null) return;

    if (empty($options)) {
        if (!empty($GLOBALS["OPTIONS"]) && is_array($GLOBALS["OPTIONS"])) $options=$GLOBALS["OPTIONS"];
    }
    if (empty($options)) return;

    $option_characters=array();
    $option_character_found=false;
    foreach($options as $option => $option_number) {
        if ($option_character_found) continue;
        if (empty($option_number[0])) continue;
        #echo "option_number[0]".$option_number[0].Br();

        if (empty($option_number[2]) || empty($option_number[2])) {
            $required_option=false;
        } else $required_option=$option_number[2];

        if (empty($option_number[0][0])) continue;
        #echo "option_number[0][0]".$option_number[0][0].Br();

        $option_character_valid=false;
        for($c=0; $c<strlen($option_number[0]); $c++) {
            if ($option_character_valid) continue;
            if ($required_option) {
                #$option_character_checks=array(strtoupper($option_number[0][$c]),strtolower($option_number[0][$c]));
                $option_character_checks=array(strtoupper($option_number[0][$c]));
            } else $option_character_checks=array(strtolower($option_number[0][$c]),strtoupper($option_number[0][$c]));
            foreach ($option_character_checks as $option_character_check) {
                if ($option_character_valid) continue;
                while (!in_array($option_character_check,$option_characters)) {
                    if ($option_number[0] == $long_option) {
                        $option_character_found=true;
                        $option_character=$option_character_check;
                    }
                    $option_characters[]=$option_character_check;
                    $option_character_valid=true;
                }
            }

        }
    }
    #print_r($option_characters);
    if ($option_character_found) {
        return $option_character;
    } else return null;
}

function Options($options=array()) {
    # begin function logic
    if (empty($options)) {
        if (!empty($GLOBALS["OPTIONS"]) && is_array($GLOBALS["OPTIONS"])) $options=$GLOBALS["OPTIONS"];
    }

    # apache (GET) options handling
    if (Mod_Php()) {
        return;
    }

    # cli options handling
    $long_options=array();
    $short_options="";
    foreach($options as $option_number) {
        if (empty($option_number[0]) || empty($option_number[0])) continue;
        $long_option=$option_number[0];
        $long_options[]=$long_option."::";
        $option_character=Options_Character($options,$long_option);
        $long_options[]=$option_character."::";
        $short_options.=$option_character."::";
        Debug("long_option=$long_option, option_character=$option_character",103);
    }

    if ($short_options != null && $short_options != "" && $long_options != null && empty($long_options)) return;
    #var_dump($short_options);
    #var_dump($long_options);

    $GLOBALS["GETOPT"]=getopt($short_options,$long_options);
    #var_dump($options);

    #var_dump($GLOBALS["GETOPT"]);

    foreach ($GLOBALS["GETOPT"] as $SETOPT => $SETOPT_VALUE) {
        # to be able to support multiple options, handling arrays must work; not enough time to get this done right now
        # work around this with multiple singular options if needed right away
        if (is_array($SETOPT_VALUE)) Usage("arrayed options are not supported yet; error processing option $SETOPT");
        if (is_string($SETOPT_VALUE) && strpos($SETOPT_VALUE,"=") !== FALSE) {
            Debug("Processing $SETOPT $SETOPT_VALUE =",103);
            $GLOBALS["GETOPT"][$SETOPT]=substr($SETOPT_VALUE,strpos($SETOPT_VALUE,"=")+1);
        } else {
            Debug("Processing $SETOPT ".(string)$SETOPT_VALUE." OK",103);
        }
    }

    $required_global_numeric_options=array("debug");
    foreach ($required_global_numeric_options as $required_global_numeric_option) {
        $option=$required_global_numeric_option;
        $option_global=strtoupper($option);
        if (!in_array($option."::", $long_options)) {
            Warning("$option is a required option with a numeric value");
        } else {
            $option_character=Options_Character($options,$option);
            $option_used=null;
            if (!empty($GLOBALS["GETOPT"][$option])) $option_used=$option;
            if (!empty($GLOBALS["GETOPT"][$option_character])) $option_used=$option_character;
            if ($option_used != null) {
                $GLOBALS["$option_global"]=1;
            }
            if (!empty($GLOBALS["GETOPT"][$option_used]) && $GLOBALS["GETOPT"][$option_used] !== false) {
                if (is_numeric($GLOBALS["GETOPT"][$option_used])) {
                    $GLOBALS["$option_global"]=$GLOBALS["GETOPT"][$option_used];
                } else {
                    if (!empty($GLOBALS["GETOPT"][$option])) $option_used="--".$option;
                    if (!empty($GLOBALS["GETOPT"][$option_character])) $option_used="-".$option_character;
                    Usage("$option_used value must be numeric",$options);
                }
            }
        }
    }

    $required_options=array("help","version");
    foreach ($required_options as $required_option) {
        $option=$required_option;
        if (!in_array($option."::", $long_options)) {
            Warning("$option is a required option");
        } else {
            if (!empty($GLOBALS["GETOPT"][$option]) || !empty($GLOBALS["GETOPT"][Options_Character($options,$option)])) {
                Usage("",$options);
            }
        }
    }

    Debug_Variable("GETOPT",101);
    Debug_Variable("long_options",101,$long_options);
    Debug_Variable("short_options",101,$short_options);

    # end function logic
}

function Private_Property($privacy_message=null) {
    if (!empty($privacy_message)) {
        if (is_readable($privacy_message)) {
            $privacy_message=file_get_contents($privacy_message);
        }
    }
    if (empty($privacy_message) && !empty($GLOBALS["PRIVACY_MESSAGE"])) {
        if (is_readable($GLOBALS["PRIVACY_MESSAGE"])) {
            $privacy_message=file_get_contents($GLOBALS["PRIVACY_MESSAGE"]);
        } else {
            $privacy_message=$GLOBALS["PRIVACY_MESSAGE"];
        }
    }
    if (empty($privacy_message)) {
        $privacy_message="Private Property";
    }
    return $privacy_message;
}

function Require_Include($include_file=null,$include_source=__FILE__) {
    if (empty($include_file)) return;
    if (empty($include_source)) return;

    $include_found=0;
    $include_path=dirname($include_source);
    while(strlen($include_path) > 0) {
        if ($include_path == "/") break;
        if (is_readable($include_path."/include/".$include_file)) {
            $include_found=1;
            require_once($include_path."/include/".$include_file);
            unset($include_file, $include_path);
            break;
        } else {
            $include_path=dirname($include_path);
        }
    }
    # i'd like this to log an error (e.g. Log_Error) and exit rather than echo ... some day
    if ($include_found != 1) { echo "can't find $include_file\n"; exit(1); }

}

function not_Usage($note="",$options=array()) {
    # begin function logic

    if (empty($GLOBALS["BASE_0"])) $GLOBALS["BASE_0"]=__FILE__;

    echo Br();
    if (Mod_Php()) {
        # this should work for web pages, too
        echo "usage: ".$GLOBALS["BASE_0"]."?<options>".Br();
    } else {
        echo "usage: ".$GLOBALS["BASE_0"]." <options>".Br();
    }
    echo Br();

    if (empty($options)) {
        if (!empty($GLOBALS["OPTIONS"]) && is_array($GLOBALS["OPTIONS"])) $options=$GLOBALS["OPTIONS"];
    }

    if (!empty($options)) {
        echo "options:".Br();
        echo Br();
    }

    foreach($options as $option => $option_number) {
        if (empty($option_number[0])) {
            echo Br();
            continue;
        }
        $option_line="  ";
        $option_character=Options_Character($options,$option_number[0]);
        if ($option_character != null) {
            $option_line.="-".$option_character." | ";
        }
        $option_line.="--".$option_number[0];

        if (empty($option_number[1]) || empty($option_number[1])) {
            $option_description="unknown";
        } else $option_description=$option_number[1];

        $option_value=null;

        if ((stristr($option_description,"[") && stristr($option_description,"]")) || (stristr($option_description,"<") && stristr($option_description,">"))) {
            if ($option_description[0] == "[") {
                $option_value=trim(substr($option_description,0,strpos($option_description,"]")+1));
                $option_description=trim(substr($option_description,strpos($option_description,"]")+1));
            }
            if ($option_description[0] == "<") {
                $option_value=trim(substr($option_description,0,strpos($option_description,">")+1));
                $option_description=trim(substr($option_description,strpos($option_description,">")+1));
            }
        }

        if (!empty($option_value)) {
            $option_line.=" ".$option_value;
        }

        $option_line=str_pad($option_line,32);

        $option_line.=" = ".$option_description;

        $option_line.=Br();
        echo $option_line;
    }

    echo Br();
    if($note != null) {
        echo "NOTE: $note".Br();
        echo Br();
    }

    # end function logic

    Stop(1);
}

function Generate_UUID() {
    # begin function logic
    Debug(__FUNCTION__."() has been deprecated; use Uuid() instead",1);
    return Uuid();
    # end function logic
}

# was Generate_UUID
function Uuid() {
    # begin function logic
    $random_string=openssl_random_pseudo_bytes(16);
    $time_low=bin2hex(substr($random_string, 0, 4));
    $time_mid=bin2hex(substr($random_string, 4, 2));
    $time_hi_and_version=bin2hex(substr($random_string, 6, 2));
    $clock_seq_hi_and_reserved=bin2hex(substr($random_string, 8, 2));
    $node=bin2hex(substr($random_string, 10, 6));
    $time_hi_and_version=hexdec($time_hi_and_version);
    $time_hi_and_version=$time_hi_and_version >> 4;
    $time_hi_and_version=$time_hi_and_version | 0x4000;
    $clock_seq_hi_and_reserved=hexdec($clock_seq_hi_and_reserved);
    $clock_seq_hi_and_reserved=$clock_seq_hi_and_reserved >> 2;
    $clock_seq_hi_and_reserved=$clock_seq_hi_and_reserved | 0x8000;
    return sprintf("%08s-%04s-%04x-%04x-%012s", $time_low, $time_mid, $time_hi_and_version, $clock_seq_hi_and_reserved, $node);
    # end function logic
}

function Version() {
    global $BASE_0,$VERSION;
    echo Br();
    echo "$BASE_0 version $VERSION".Br();
    echo Br();
    Stop(0);
}

function Warning($warning_message,$warning_sleep=3) {
    # begin function logic
    echo Br();
    echo "WARNING !!".Br();
    echo "WARNING !!  ".$warning_message.Br();
    echo "WARNING !!".Br();
    echo Br();

    if ($warning_sleep > 0) {
        echo "Pausing for $warning_sleep seconds. (";
        while ($warning_sleep > 0) {
            echo "$warning_sleep";
            if ($warning_sleep > 1) echo ".";
            sleep(1);
            $warning_sleep--;
        }
        echo ")".Br();
    }
    # end function logic
}

function Which($which_basename=null,$which_abort=true) {
    # start function logic
    if (empty($which_basename)) return;

    $which_basename=basename($which_basename);
    if (empty($GLOBALS["PATH"])) $GLOBALS["PATH"]=$_SERVER["PATH"];
    $path_parts=explode(":",$GLOBALS["PATH"]);
    foreach($path_parts as $path_part) {
        $dirname_basename=$path_part."/".$which_basename;
        if (is_readable($dirname_basename)) {
            #Debug("Which() found $dirname_basename ...",102);
            return $dirname_basename;
        }
    }
    if ($which_abort) {
        Aborting("Which() can't find $which_basename",2);
    } else return null;
    # end function logic
}

/**
     * Parses INI file adding extends functionality via ":base" postfix on namespace.
     *
     * @param string $filename
     * @return array
*/
function parse_ini_file_extended($filename) {
        $p_ini = parse_ini_file($filename, true);
        $config = array();
        foreach($p_ini as $namespace => $properties){
	    if (strpos($namespace, ":") === false)
                continue;

            list($name, $extends) = explode(':', $namespace);
            $name = trim($name);
            $extends = trim($extends);
            // create namespace if necessary
            if(!isset($config[$name])) $config[$name] = array();
            // inherit base namespace
            if(isset($p_ini[$extends])){
                foreach($p_ini[$extends] as $prop => $val)
                    $config[$name][$prop] = $val;
            }
            // overwrite / set current namespace values
            foreach($properties as $prop => $val)
            $config[$name][$prop] = $val;
        }
        return $config;
}

function exec_curl($url, $options) {
    Debug("Calling curl_exec to apiRouteUrl = " . $url,7);
    $ch = curl_init($url);

    foreach ($options as $opt=>$val) {
        Debug ("setting curloption $opt to " . var_export($val, true), 9);
        curl_setopt($ch, $opt, $val);
    }

    $output = curl_exec($ch);
    Debug("Curl OUTPUT: $output",9);
    
    $error = curl_error($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    curl_close($ch);
    return array('output'=>$output, 'error'=>$error, 'httpCode'=>$httpCode);
}


# Main Logic

# validate HOSTNAME
if (empty($HOSTNAME)) {
    Aborting("can't determine HOSTNAME");
}

# validate DATACENTER
foreach ($BASE_DATACENTERS as $BASE_DATACENTER) {
    if (strpos($HOSTNAME,$BASE_DATACENTER.'-') !== false) $DATACENTER=$BASE_DATACENTER;
    break;
}
if (empty($DATACENTER)) {
    $DATACENTER="unknown";
    $BASE_DATACENTER=$DATACENTER;
}

# validate ENVIRONMENT
foreach ($BASE_ENVIRONMENTS as $BASE_ENVIRONMENT) {
    if (strpos($HOSTNAME,"-".$BASE_ENVIRONMENT) !== false) $ENVIRONMENT=$BASE_ENVIRONMENT;
}
if (empty($ENVIRONMENT)) $ENVIRONMENT="prod";
if (empty($ENVIRONMENT)) {
    $ENVIRONMENT="unknown";
    $BASE_ENVIRONMENT=$ENVIRONMENT;
}

if (empty($MACHINE_ENVIRONMENT)) $MACHINE_ENVIRONMENT=$ENVIRONMENT;

