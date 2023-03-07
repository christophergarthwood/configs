#!/usr/bin/env bash
#======================================================================================================================
#     ▄█    █▄       ▄████████    ▄████████ ████████▄     ▄████████    ▄████████ 
#    ███    ███     ███    ███   ███    ███ ███   ▀███   ███    ███   ███    ███ 
#    ███    ███     ███    █▀    ███    ███ ███    ███   ███    █▀    ███    ███ 
#   ▄███▄▄▄▄███▄▄  ▄███▄▄▄       ███    ███ ███    ███  ▄███▄▄▄      ▄███▄▄▄▄██▀ 
#  ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀███████████ ███    ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   
#    ███    ███     ███    █▄    ███    ███ ███    ███   ███    █▄  ▀███████████ 
#    ███    ███     ███    ███   ███    ███ ███   ▄███   ███    ███   ███    ███ 
#    ███    █▀      ██████████   ███    █▀  ████████▀    ██████████   ███    ███ 
#======================================================================================================================
# SYNOPSIS
#    usage: <script name> -a <sample_argument> -d 
#    Options:
#    -d      Turn on debugging.
#    -h      Display this message.
#
#    Network tool installation and debugging potential.
#
#    Example usage:./ubuntuNetworkDebug.sh -d
#======================================================================================================================
#- IMPLEMENTATION
#-    version         1.0
#-    author          christopher wood
#-    copyright       None
#-    license         GNU General Public License
#-    script_id       UND_001
#-
#-    /usr/bin/bash -n and shellcheck used for compliance.
#-    To perform a syntax check/dry run of your bash script run:
#-        -bash -n myscript.sh
#-    To produce a trace of every command executed run:
#-        -bash -v myscripts.sh
#-    To produce a trace of the expanded command use:
#-        -bash -x myscript.sh
#-
#- The layers in the TCP/IP network model, in order, include:
#- Layer 5: Application
#- Layer 4: Transport
#- Layer 3: Network/Internet
#- Layer 2: Data Link
#- Layer 1: Physical
#- Reference: https://www.redhat.com/sysadmin/beginners-guide-network-troubleshooting-linux
#======================================================================================================================
#  HISTORY
#     2023/03/07 - Inception
#
#======================================================================================================================
# END_OF_HEADER
#======================================================================================================================

#*** CONFIGURATION ***
############################################################################################################################################
#   ▄████████  ▄██████▄  ███▄▄▄▄      ▄████████  ▄█     ▄██████▄  ███    █▄     ▄████████    ▄████████     ███      ▄█   ▄██████▄  ███▄▄▄▄   
#  ███    ███ ███    ███ ███▀▀▀██▄   ███    ███ ███    ███    ███ ███    ███   ███    ███   ███    ███ ▀█████████▄ ███  ███    ███ ███▀▀▀██▄ 
#  ███    █▀  ███    ███ ███   ███   ███    █▀  ███▌   ███    █▀  ███    ███   ███    ███   ███    ███    ▀███▀▀██ ███▌ ███    ███ ███   ███ 
#  ███        ███    ███ ███   ███  ▄███▄▄▄     ███▌  ▄███        ███    ███  ▄███▄▄▄▄██▀   ███    ███     ███   ▀ ███▌ ███    ███ ███   ███ 
#  ███        ███    ███ ███   ███ ▀▀███▀▀▀     ███▌ ▀▀███ ████▄  ███    ███ ▀▀███▀▀▀▀▀   ▀███████████     ███     ███▌ ███    ███ ███   ███ 
#  ███    █▄  ███    ███ ███   ███   ███        ███    ███    ███ ███    ███ ▀███████████   ███    ███     ███     ███  ███    ███ ███   ███ 
#  ███    ███ ███    ███ ███   ███   ███        ███    ███    ███ ███    ███   ███    ███   ███    ███     ███     ███  ███    ███ ███   ███ 
#  ████████▀   ▀██████▀   ▀█   █▀    ███        █▀     ████████▀  ████████▀    ███    ███   ███    █▀     ▄████▀   █▀    ▀██████▀   ▀█   █▀  
############################################################################################################################################
#- trap ctrl-c and call ctrl_c()
trap ctrl_c INT

IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

#set -o errexit   # abort on nonzero exitstatus, add || true to commands that allow you to fail (-e).
set -o nounset   # abort on unbound variable, (-u)
set -o pipefail  # don\'t hide errors within pipes to catch mysqldump fails in e.g. mysqldump |gzip. The exit status of the last command that threw a non-zero exit code is returned.
#set -o xtrace    # trace what gets executed, good for debugging (-x)
set -a           # Automatically mark variables and functions which are modified or created for export to the environment of subsequent commands.


#*** VARIABLES ***
############################################################################################################################################
#   ▄█    █▄     ▄████████    ▄████████  ▄█     ▄████████ ▀█████████▄   ▄█          ▄████████    ▄████████ 
#  ███    ███   ███    ███   ███    ███ ███    ███    ███   ███    ███ ███         ███    ███   ███    ███ 
#  ███    ███   ███    ███   ███    ███ ███▌   ███    ███   ███    ███ ███         ███    █▀    ███    █▀  
#  ███    ███   ███    ███  ▄███▄▄▄▄██▀ ███▌   ███    ███  ▄███▄▄▄██▀  ███        ▄███▄▄▄       ███        
#  ███    ███ ▀███████████ ▀▀███▀▀▀▀▀   ███▌ ▀███████████ ▀▀███▀▀▀██▄  ███       ▀▀███▀▀▀     ▀███████████ 
#  ███    ███   ███    ███ ▀███████████ ███    ███    ███   ███    ██▄ ███         ███    █▄           ███ 
#  ███    ███   ███    ███   ███    ███ ███    ███    ███   ███    ███ ███▌    ▄   ███    ███    ▄█    ███ 
#   ▀██████▀    ███    █▀    ███    ███ █▀     ███    █▀  ▄█████████▀  █████▄▄██   ██████████  ▄████████▀  
############################################################################################################################################

#flow of control
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${0}" )" && pwd )
execute=0;
export WORKDIR="";
WORKDIR=$(dirname $0);

#application specific
export VERSION_NAME="UND";
export VERSION_MAJOR="1";
export VERSION_MINOR="0";
export no_date_prefix="";               #used with debugging framework
export arg_incoming_argument="";
export arg_debug="0";
export target_name="www.google.com";
export target_ip="8.8.8.8";
export the_tools=( net-tools iftop vnstat iptraf hping3 dstat slum bmon nmap );
export the_network_device="eth0";
export the_hops=4;

#setup paths for executables.
export command_apt=$(which apt);
export command_ping=$(which ping);
export command_ufw=$(which ufw);
export command_ls=$(which ls);
export command_ip=$(which ip);
export command_ethtool=$(which ethtool);
export command_cat=$(which cat);
export command_traceroute=$(which traceroute);
export command_nslookup=$(which nslookup);
export command_netstat=$(which netstat);
export the_commands=( ${command_apt} ${command_ping} ${command_ufw} ${command_ls} ${command_ip} ${command_ethtool} ${command_cat} ${command_traceroute} ${command_nslookup} ${command_netstat} )

# - INCLUDES
############################################################################################################################################
#   ▄█  ███▄▄▄▄    ▄████████  ▄█       ███    █▄  ████████▄     ▄████████    ▄████████ 
#  ███  ███▀▀▀██▄ ███    ███ ███       ███    ███ ███   ▀███   ███    ███   ███    ███ 
#  ███▌ ███   ███ ███    █▀  ███       ███    ███ ███    ███   ███    █▀    ███    █▀  
#  ███▌ ███   ███ ███        ███       ███    ███ ███    ███  ▄███▄▄▄       ███        
#  ███▌ ███   ███ ███        ███       ███    ███ ███    ███ ▀▀███▀▀▀     ▀███████████ 
#  ███  ███   ███ ███    █▄  ███       ███    ███ ███    ███   ███    █▄           ███ 
#  ███  ███   ███ ███    ███ ███▌    ▄ ███    ███ ███   ▄███   ███    ███    ▄█    ███ 
#  █▀    ▀█   █▀  ████████▀  █████▄▄██ ████████▀  ████████▀    ██████████  ▄████████▀  
############################################################################################################################################

#Paths for sub-functions like the logging framework.
#export function_dirs="/u/yamm/cwood/FPATH";
#if [ -d "${function_dirs}" ];
#then
#    export FPATH="${function_dirs:-""}:${FPATH:-""}";
#else
#	echo "${function_dirs} does not exist."
#	echo "ksh can use FPATH as the source of smaller functional scripts that act as functions."
#	echo "When trying to build ${function_dirs} into FPATH a problem was encountered."
#	echo "This script won't function properly without pointing to where your functions are."
#	exit 20; #ENOTDIR, no directory
#fi
function ctrl_c {
  msg_error "CTRL+C utilized..."
  msg_warning "...clean-up of temporary files and actions halted."
  exit -1
}

function banner {
    #================================================================
    # General function to display a banner, when desired, per 
    # function call.
    #================================================================
    boundary=72
    if [ ! -z $1 ];
    then
        output_str=$1;
        output_len=$(echo "${output_str}" | wc -c);
        delta=$(( boundary - output_len ));
        for i in $(seq 1 "${delta}" )
        do
            output_str+="=";
        done
        msg_info "${output_str}"
    else
        msg_info "=======================================================================";
    fi

}

function get_ISO8601 {
	funct_result=$(date +'%Y%m%d')
}


function get_ISO8601_full {
	funct_result=$(date +'%Y-%m-%d %H:%M:%S')
}


function get_date {
	funct_result=$(date +'%Y%m%d:%H%M')
}

function msg_debug {
  export spacing=8;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    #typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")" "
    typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")
  fi
  typeset prefix="${d}"
  typeset type="DEBUG:"
  while [[ $# != 0 ]]
  do
     echo "$1" | {
      while read -r line
      do
          printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 2>&1
      done
    }
    shift
  done
}


function msg_info {
  export spacing=8;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    #typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")" "
    typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")
  fi
  typeset prefix="${d}"
  typeset type="INFO:"
  while [[ $# != 0 ]]
  do
    echo "$1" | {
      while read -r line
      do
        printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 2>&1
      done
    }
    shift
  done
}

function msg_emerg {
  export error_msg="${1}"
  export spacing=8;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    #typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")" "
    typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")
  fi
  typeset prefix="${d}"
  typeset type="CRITICAL:"
  while [[ $# != 0 ]]
  do
     echo "$1" | {
      while read -r line
      do
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" >&2
      done
    }
    shift
  done
  error_exit "${error_msg}"
}


function msg_error {
  export spacing=8;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    #typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")" "
    typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")
  fi
  typeset prefix="${d}"
  typeset type="ERROR:"
  while [[ $# != 0 ]]
  do
     echo "$1" | {
      while read -r line
      do
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" >&2
      done
    }
    shift
  done
}

function msg_warning {
  export spacing=8;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    #typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")" "
    typeset d=$(TZ='GST-0' date +"[%Y-%m-%d %H:%M:%S]")
  fi
  typeset prefix="${d}"
  typeset type="WARN:"
  while [[ $# != 0 ]]
  do
    echo "$1" | {
      while read -r line
      do
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 2>&1
      done
    }
    shift
  done
}

function error_exit {
    echo " ============ ERROR ===========" >&2
    echo " |  ____|                      " >&2
    echo " | |__   _ __ _ __ ___  _ __   " >&2
    echo " |  __| | '__| '__/ _ \| '__|  " >&2
    echo " | |____| |  | | | (_) | |     " >&2
    echo " |______|_|  |_|  \___/|_|     " >&2
    echo " ============ ERROR ===========" >&2
    echo "${the_argument}";

    get_date;
    exit 1
}

function usage {
    cat <<@EOF
    usage: <script name> -d
    Options:
    -d      Enable debug output [DEBUG].

    Example usage: ./ubuntuNetworkDebug.ksh -d
@EOF
#        if [ $# -gt 0 ];
#       then
#         if [ $1 -eq 1 ];
#         then
#           exit
#         fi
#       fi
}


#*** FUNCTIONS ***
############################################################################################################################################
#     ▄████████ ███    █▄  ███▄▄▄▄    ▄████████     ███      ▄█   ▄██████▄  ███▄▄▄▄      ▄████████ 
#    ███    ███ ███    ███ ███▀▀▀██▄ ███    ███ ▀█████████▄ ███  ███    ███ ███▀▀▀██▄   ███    ███ 
#    ███    █▀  ███    ███ ███   ███ ███    █▀     ▀███▀▀██ ███▌ ███    ███ ███   ███   ███    █▀  
#   ▄███▄▄▄     ███    ███ ███   ███ ███            ███   ▀ ███▌ ███    ███ ███   ███   ███        
#  ▀▀███▀▀▀     ███    ███ ███   ███ ███            ███     ███▌ ███    ███ ███   ███ ▀███████████ 
#    ███        ███    ███ ███   ███ ███    █▄      ███     ███  ███    ███ ███   ███          ███ 
#    ███        ███    ███ ███   ███ ███    ███     ███     ███  ███    ███ ███   ███    ▄█    ███ 
#    ███        ████████▀   ▀█   █▀  ████████▀     ▄████▀   █▀    ▀██████▀   ▀█   █▀   ▄████████▀  
############################################################################################################################################


function validate_program {

    #================================================================
    # Check all CLI arguments before we start any work
    #  -- examples are below for purposes of how an implimentation might look
    #================================================================
    execute=1;
    msg_info "Validating arguments.";

    #make sure the script doesn't run as root (security concern)
    whoami=$(id -u)
    if [ "${whoami}" -eq 0 ];
    then
        msg_emerg "This script is not authorized to run as root."
    fi

    #test for existence of all commands, if one is missing ensure invoker understands this.
    for the_command in ${the_commands[@]}
    do
        if ! [ -f ${the_command} ];
        then
    	    msg_warning "...FAILED to find ${the_command}";
        fi
    done

    #if [[ -z $arg_incoming_argument ]];
    #then
    #    msg_error "Cannot find an argument variable  Without the argument variable no processing can occur.  Aborting...";
    #    execute=0;
    #fi

    #[[ $state_proj -eq 1 && $state_mdl -eq 1 && $state_target -eq 1 && $state_output -eq 1 && $state_error_log -eq 1 ]] && execute=1;

}

function prototype {
    #===============================================================================
    #-- EXECUTE each function as passed in as $1 using the batch system
    #===============================================================================
    [[ ! -z "$arg_debug" ]] && msg_debug "Entered prototype";

    export the_function="${1:-"no argument passed"}";
    msg_info "Processing (argument 1) \"${the_function}\".";

    #execute a comand and save it to an array
    the_results=( $(ls -1 ~) );
    #was the comand successful?
    status=$?
    if [ "${status}" -ne 0 ];
    then
        error_msg="The environment variable RECON_NEURAL_TRAINING_OUTPUT_DIR (${RECON_NEURAL_TRAINING_OUTPUT_DIR}) points to a directory that doesn't exist.  We tried to create it for you but mkdir -p returned a status of (${Status}).  Please investigate, aborting execution due to failure to specify a valid output location.";
        msg_error "${error_msg}";
        msg_emerg "${error_msg}";
    fi

    for the_result in ${the_results[@]}
    do
        msg_debug "This file is being processed: ${the_result}.";
    done

    [[ ! -z "$arg_debug" ]] && msg_debug "Exited prototype";
}


function install_network_tools {

    #===============================================================================
    #-- Install Network tools necessary to debug 
    #===============================================================================
    [[ ! -z "$arg_debug" ]] && msg_debug "Entered install_network_tools";
    banner "Network Tools Installation";
    msg_debug "...installing minimal network debugging tools."
    for the_tool in ${the_tools[@]}
    do
        sudo apt install "${the_tool}";
        status=$?
        if [ "${status}" -ne 0 ];
        then
	    msg_debug "......successfully installed ${the_tool}";
        fi
    done
    [[ ! -z "$arg_debug" ]] && msg_debug "Exited install_network_tools";
}

function layer0 {

    #===============================================================================
    #-- Variable display and firewall down
    #===============================================================================
    [[ ! -z "$arg_debug" ]] && msg_debug "Entered layer0";
    banner "Variables and Firewall Down";
    msg_debug "...establishing target NAME [${target_name}]";
    msg_debug "...establishing target IP [${target_ip}]";
    if [ -f $command_ufw ];
    then
	    sudo $command_ufw disable;
	    status=$?;
	    if [ "${status}" -ne 0 ];
	    then
		msg_debug "......SUCCESS disabled firewall.";
	    else
		msg_warning "......FAIL to disable firewall.";
	    fi
    else
	    msg_warning "......FAIL, could not find firewall command.";
    fi
    msg_debug " ";
    [[ ! -z "$arg_debug" ]] && msg_debug "Exited layer0";
}

function layer1 {
    #===============================================================================
    #-- Network device information and status (hardware)
    #===============================================================================
    banner "Layer1: The Physical Layer";
    if [ -f $command_ip ];
    then
        sudo $command_ip link set "${the_network_device}" up;
        sudo $command_ip addr | grep "${the_network_device}";
        msg_debug "...${the_network_device} UP";
        msg_debug "...${the_network_device} status";
        sudo $command_ip -s link show "${the_network_device}"
    else
	msg_warning "......FAIL, could not find ip (network) command";
    fi

    if [ -f $command_ethtool ];
    then
        msg_debug "...${the_network_device} details";
        sudo $command_ethtool "${the_network_device}";
    else
	msg_warning "......FAIL, could not find ethtool (network) command";
    fi
}

function layer2 {
    #===============================================================================
    #-- Data Link Layer
    #===============================================================================
    banner "Layer2: The data link layer";
    if [ -f $command_ip ];
    then
        sudo $command_ip neighbor show
    else
	msg_warning "......FAIL, could not find ip (network) command";
    fi
}

function layer3 {
    #===============================================================================
    #-- Routing layer
    #===============================================================================
    banner "Layer 3: The network/internet layer";
    if [ -f $command_ip ];
    then
        sudo $command_ip -br address show;
    else
	msg_warning "......FAIL, could not find ip (network) command";
    fi

    if [ -f $command_ping ];
    then
        msg_debug "...${command_ping} -c ${the_hops} ${target_ip}";
        $command_ping -c "${the_hops}" "${target_ip}";

        msg_debug "...${command_ping} -c ${the_hops} ${target_name}";
        $command_ping -c "${the_hops}" "${target_name}";
    else
	msg_warning "......FAIL, could not find ping command";
    fi

    if [ -f /etc/resolv.conf ];
    then
        msg_debug "...DNS settings.";
        $command_cat /etc/resolv.conf;
    else
	msg_warning "......FAIL, could not find /etc/resolv.conf";
    fi

    if [ -f $command_traceroute ];
    then
        msg_debug "...${command_traceroute} ${the_hops} ${target_ip}";
        $command_traceroute -"${the_hops}" "${target_ip}";

        msg_debug "...${command_traceroute} ${the_hops} ${target_name}";
        $command_traceroute -"${the_hops}" "${target_name}";
    else
	msg_warning "......FAIL, could not find traceroute command.";
    fi

    if [ -f $command_ip ];
    then
        msg_debug "...${command_ip} route show";
        sudo $command_ip route show;
    else
	msg_warning "......FAIL, could not find ip (network) command.";
    fi

    if [ -f $command_nslookup ];
    then
        msg_debug "...${command_nslookup} ${target_name}";
        sudo $command_nslookup "${target_name}";
    else
	msg_warning "......FAIL, could not find nslookup command.";
    fi
}

function layer4 {
    #===============================================================================
    #-- Communications (Traffic)
    #===============================================================================
    banner "Layer 4: The transport layer";
    msg_debug "...show all potential data exchanges";
    if [ -f $command_netstat ];
    then
        #sudo ss -tunlp4
        sudo $command_netstat -tulnp
    else
	msg_warning "......FAIL, could not find netstat command.";
    fi
}

#*** MAIN ***
############################################################################################################################################
#     ▄▄▄▄███▄▄▄▄      ▄████████  ▄█  ███▄▄▄▄   
#   ▄██▀▀▀███▀▀▀██▄   ███    ███ ███  ███▀▀▀██▄ 
#   ███   ███   ███   ███    ███ ███▌ ███   ███ 
#   ███   ███   ███   ███    ███ ███▌ ███   ███ 
#   ███   ███   ███ ▀███████████ ███▌ ███   ███ 
#   ███   ███   ███   ███    ███ ███  ███   ███ 
#   ███   ███   ███   ███    ███ ███  ███   ███ 
#    ▀█   ███   █▀    ███    █▀  █▀    ▀█   █▀  
############################################################################################################################################

function main {
    get_date
    start_time=$(date +'%s')
    msg_info "BEGIN $script_name"

    #================================================================
    # Argument management
    #================================================================
    msg_info "Processing arguments."
    while getopts "hda:" opt; do
        case "$opt" in
            d)
                arg_debug=1;
                ;;
            #a)
            #    arg_incoming_argument=${OPTARG};
            #    ;;
            h)
                usage
                exit 1
                ;;
            :)
                msg_debug "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
            \?)
                msg_emerg "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    validate_program
    if [ "${execute}" -eq 1 ];
    then
        msg_info "${VERSION_NAME} ${VERSION_MAJOR}.${VERSION_MINOR}"
        [[ ! -z "$arg_debug" ]] && msg_debug "Debugging selected and tested for."
	msg_info "...priming sudo with an ls, supply your password";
        the_result=$(sudo $command_ls);

        #prototype "${arg_incoming_argument}"
	install_network_tools
	layer0
	layer1
	layer2
	layer3
	layer4

        end_time=$(date +%s);
        msg_info "Execution time for ${script_name} was $((end_time - start_time)) s.";
        get_date;
        msg_info "END ${script_name}";
    else
        usage
        echo " "
        msg_emerg "There was a problem with argument passing, an argument was not compliant.  Exiting..."
    fi
}

main "${@}"
