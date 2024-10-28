#!/usr/bin/env bash
#================================================================
# HEADER
#
# Creates environment sufficient for JBooks AI/ML efforts.
#================================================================

#*** VARIABLES ***
#############################################################
#  \ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____/ ___| 
#   \ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _| \___ \ 
#    \ V / ___ \|  _ < | | / ___ \| |_) | |___| |___ ___) |
#     \_/_/   \_\_| \_\___/_/   \_\____/|_____|_____|____/ 
#############################################################
#arguments passed via PBS are made available, if not PBS then this code will resolve key=value pairs
if [ -z "${PBS_JOBID}" ];
then
    for i in $*
    do
     msg_debug "...evaluating ${i}";
     eval $i;
    done
fi

#flow of control
this_script=restore_account;
execute=0;

#application specific
export TARGET_FOLDER="/home/jupyter/projects";
export DATA_FOLDER="${TARGET_FOLDER}/data";
export WORK_FOLDER="${TARGET_FOLDER}/work";
export TARGET_BUCKET="usfs-gcp-rand-test3-data-usc1";
export STATE_DIR="./";
#arg_incoming_region passed by way of arguments
GLOBAL_DTG=${GLOBAL_DTG};
GLOBAL_YMD=${GLOBAL_YMD};

#repos=( git@github.com:christophergarthwood/jbooks.git git@github.com:christophergarthwood/configs.git git@github.com:christophergarthwood/ai_multivariate.git git@github.com:christophergarthwood/ai_computer_vision.git git@github.com:christophergarthwood/ai_basic.git git@github.com:christophergarthwood/my_code.git git@github.com:USDAForestService/network_metrics.git git@github.com:USDAForestService/jbooks.git )
#repos_names=( my_jbooks my_configs ai_multivariate ai_computer_vision ai_basic my_code usda_network_metrics usda_jbooks )
repos=( git@github.com:christophergarthwood/jbooks.git git@github.com:christophergarthwood/configs.git git@github.com:christophergarthwood/ai_multivariate.git git@github.com:christophergarthwood/ai_computer_vision.git git@github.com:christophergarthwood/ai_basic.git git@github.com:USDAForestService/network_metrics.git git@github.com:USDAForestService/jbooks.git )
repos_names=( my_jbooks my_configs ai_multivariate ai_computer_vision ai_basic usda_network_metrics usda_jbooks )

#define the arrays that will hold 'jobs' which correlate to each array position above (key to the dictionary)
typeset -A JOBS;
typeset -A JOB;

#Paths
#FPATH passed by way of invocation, PBS spooling of functions makes some aspects of var assignment difficult

#*** FUNCTIONS ***
#############################################################
#    |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
#    | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
#    |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
#    |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 
#############################################################

job_stop () {

    if [ ! -z "${PBS_JOBNAME}" ];
    then
        job_name="${PBS_JOBNAME}"
    else
        job_name="${1}"
    fi
    current_region="${arg_incoming_region}"
    get_ISO8601
    job_name="${funct_result}_${current_region}_${job_name}.stop"
    get_ISO8601_full
    echo "${funct_result}" >> "${STATE_DIR}/${job_name}"

}

job_start () {

    if [ ! -z "${PBS_JOBNAME}" ];
    then
        job_name="${PBS_JOBNAME}"
    else
        job_name="${1}"
    fi
    current_region="${arg_incoming_region}"
    get_ISO8601
    job_name="${funct_result}_${current_region}_${job_name}.start"
    get_ISO8601_full
    echo "${funct_result}" >> "${STATE_DIR}/${job_name}"

}

get_ISO8601_full () {
	funct_result=$(date +'%Y-%m-%d %H:%M:%S')
}

job_complete () {

    if [ ! -z "${PBS_JOBNAME}" ];
    then
        job_name="${PBS_JOBNAME}"
    else
        job_name="${1}"
    fi
    current_region="${arg_incoming_region}"
    get_ISO8601
    job_name="${funct_result}_${current_region}_${job_name}.complete"
    get_ISO8601_full
    echo "${funct_result}" >> "${STATE_DIR}/${job_name}"

}

get_date () {
	funct_result=$(date +'%Y%m%d:%H%M')
}

get_ISO8601 () {
	funct_result=$(date +'%Y%m%d')
}

banner () {
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

#------------------------------------------------------------------------------#
# CONFIGURATION IDENTIFICATION:
# $HeadURL$
# @(#)$Id$
#BOP --------------------------------------------------------------------------#
#
# !ROUTINE: msg_info
#
# !DESCRIPTION:
#   To printf info message to stderr (prefixed with INFO).
#   Assumes FPATH and Ksh utilization, if not understood research before use.
#
# !INPUT PARAMETERS:
#   1+(in) : message to printf
#
#EOP --------------------------------------------------------------------------#
msg_info () {

  echo "Entered msg_info"
  export spacing=6;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    typeset d=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")" "
  fi
  typeset prefix="${d}"
  typeset type="INFO:"
  while [[ $# != 0 ]]
  do
    printf "$1" | {
      while read -r line
      do
#        printf "${prefix} $line" 1>&2
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 1>&2
      done
    }
    shift
  done
}

#------------------------------------------------------------------------------#
# CONFIGURATION IDENTIFICATION:
# $HeadURL$
# @(#)$Id$
#BOP --------------------------------------------------------------------------#
#
# !ROUTINE: msg_debug
#
# !DESCRIPTION:
#   To printf debug message to stderr (prefixed with DEBUG).
#   Assumes FPATH and Ksh utilization, if not understood research before use.
#
# !INPUT PARAMETERS:
#   1+(in) : message to printf
#
#EOP --------------------------------------------------------------------------#
msg_debug () {
  export spacing=6;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    typeset d=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")" "
  fi
  typeset prefix="${d}"
  typeset type="DEBUG:"
  while [[ $# != 0 ]]
  do
    printf "$1" | {
      while read -r line
      do
        #printf "${prefix} $line" 1>&2
        printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 1>&2
      done
    }
    shift
  done
}


#------------------------------------------------------------------------------#
# CONFIGURATION IDENTIFICATION:
# $HeadURL$
# @(#)$Id$
#BOP --------------------------------------------------------------------------#
#
# !ROUTINE: msg_emerg
#
# !DESCRIPTION:
#   printf fatal / emergency message and exit script.
#   Assumes FPATH and Ksh utilization, if not understood research before use.
#
# !INPUT PARAMETERS:
#   1+(in) : message to printf
#
#EOP --------------------------------------------------------------------------#
msg_emerg () {
  export spacing=6;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    typeset d=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")" "
  fi
  typeset prefix="${d}"
  typeset type="EMERG:"
  while [[ $# != 0 ]]
  do
    printf "$1" | {
      while read -r line
      do
#        printf "${prefix} $line" 1>&2
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 1>&2
      done
    }
    shift
  done
  exit 128;
}

#------------------------------------------------------------------------------#
# CONFIGURATION IDENTIFICATION:
# $HeadURL$
# @(#)$Id$
#BOP --------------------------------------------------------------------------#
#
# !ROUTINE: msg_error
#
# !DESCRIPTION:
#   To printf error message to stderr (prefixed with ERROR).
#   Assumes FPATH and Ksh utilization, if not understood research before use.
#
# !INPUT PARAMETERS:
#   1+(in) : message to printf
#
#EOP --------------------------------------------------------------------------#
msg_error () {
  export spacing=6;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    typeset d=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")" "
  fi
  typeset prefix="${d}"
  typeset type="ERROR:"
  while [[ $# != 0 ]]
  do
    printf "$1" | {
      while read -r line
      do
#        printf "${prefix} $line" 1>&2
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 1>&2
      done
    }
    shift
  done
}

#------------------------------------------------------------------------------#
# CONFIGURATION IDENTIFICATION:
# $HeadURL$
# @(#)$Id$
#BOP --------------------------------------------------------------------------#
#
# !ROUTINE: msg_warning
#
# !DESCRIPTION:
#   To printf warning message to stderr (prefixed with WARNING).
#   Assumes FPATH and Ksh utilization, if not understood research before use.
#
# !INPUT PARAMETERS:
#   1+(in) : message to printf
#
#EOP --------------------------------------------------------------------------#
msg_warning () {
  export spacing=6;
  if [[ -n "$no_date_prefix" ]]
  then
    typeset d=" "
  else
    typeset d=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")" "
  fi
  typeset prefix="${d}"
  typeset type="WARN:"
  while [[ $# != 0 ]]
  do
    printf "$1" | {
      while read -r line
      do
#        printf "${prefix} $line" 1>&2
         printf "%s%+${spacing}s %s\\n" "${prefix}" "$type" "$line" 1>&2
      done
    }
    shift
  done
}

#############################################################
# @description Validates that all required arguments are present prior
# to attempting execution.  This is where your "contract" is vetted.
#
#
# @arg $config Configuration file location.
# @arg $env_config Environmental configuration file.
# @arg $region_env_config Regional, specific to that region, configuration file for the environment.
# @arg $arg_incoming_region Actual region name used to determine how to process the data.
#
# @stdout None
#
# @see main
validate_arguments () {

    execute=1;
    if [ -z "${config}" ];
    then
        execute=0;
    fi
    if [ -z "${env_config}" ];
    then
        execute=0;
    fi
    if [ -z "${region_env_config}" ];
    then
        execute=0;
    fi
    if [ -z "${arg_incoming_region}" ];
    then
        execute=0;
    fi

}

# @description This function should validate all requirements for the execution
# of the task prior to attempting the task.  This might include checking for existing
# directories, required inputs, or executables.
#
# @noargs
#
# @see main
validate_template () {

    #==============================================================================="
    #-- Validate conditions for success
    #==============================================================================="
    #if [ ! -f "${BIOCAST_EXE}" ];
    #then
    #    msg_emerg "${this_script} failed.  ${BIOCAST_EXE} does not exist, cannot proceed for this run.";
    #fi
    msg_debug "Consider validation of incoming / minimal requirements completed.";

}

# @description This function "prepares" the necessary files or functions that are needed
# for this task.  Prepping might be copying file(s) or sleeping for 30 seconds while 
# waiting for another process to finish.
#
# @noargs
#
# @see main
prep_template () {


    #==============================================================================="
    #-- used to "prepare" whatever is necessary prior to run (full blown execution).
    #==============================================================================="
    banner "template:prep_template";

    msg_info "Making save folders:"
    mkdir -p "${DATA_FOLDER}";
    mkdir -p "${WORK_FOLDER}";
    msg_debug "";


}

# @description This function represents the actual execution of the task's purpose.
# This function is where the actual work is done.
#
# @noargs
#
# @see main
run_template () {

    #==============================================================================="
    #-- Execute main mechanism
    #==============================================================================="
    banner "template:run_template";
    export OUT_DATE="";
    get_ISO8601;
    OUT_DATE="${funct_result}";
    msg_debug "${OUT_DATE}";

    msg_info "Creating repositories"
    export COUNTER=0
    for repo in "${repos[@]}"
    do
      msg_debug "git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]}"
      git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]}
      (( COUNTER++ ))
    done


    msg_debug "gsutil of target bucket to local machine..."
    msg_debug "...gsutil -m cp -r gs://${TARGET_BUCKET}/ ${DATA_FOLDER}"
    gsutil -m cp -r "gs://${TARGET_BUCKET}/" "${DATA_FOLDER}"

    msg_info ".RC file copy:"
    configs_to_copy=( .bashrc_mine .bashrc_alias .bashrc_keys .bashrc_machines .vimrc .inputrc .gitignore )
    for config in "${configs_to_copy[@]}"
    do
        msg_debug "...copying ${config} to ~";
        cp "$WORK_FOLDER/my_configs/${config}" ~;
    done
}

# @description This function represents the final tasks performed after a "run".
# Migration of files, tarball setup, or cleaning of log files are examples of what
# might be run during this task.
#
# @noargs
#
# @see main
post_template () {

    #==============================================================================="
    #-- Perform clean-up functions appropriate for biocast completion
    #==============================================================================="
    banner "template:post_template";
    msg_debug "Consider post cleanup functions completed.";
    job_complete "${this_script}";

    msg_debug "";
}

#*** MAIN ***
#############################################################
#       |  \/  |  / \  |_ _| \ | |
#       | |\/| | / _ \  | ||  \| |
#       | |  | |/ ___ \ | || |\  |
#       |_|  |_/_/   \_\___|_| \_|
#############################################################
start_time=$(date +%s);
get_date
msg_info "BEGIN $this_script at $funct_result";

validate_arguments
if [ ! $execute ];
then
  error_msg="Minimal arguments were not supplied.  Check invoking program to ensure arguments were passed properly.";
  msg_error "${error_msg}";
  msg_emerg "${error_msg}  Aborting execution.";
fi

#==============================================================================="
#-- Source Configuration files passed in
#==============================================================================="
job_start "${this_script}"

#==============================================================================="
#-- EXECUTE"
#==============================================================================="
echo "Begin"
printf "Begin"
msg_info "Begin"

prep_template
validate_template
run_template
post_template

end_time=$(date +%s);
msg_info "Execution time was $((end_time - start_time)) s.";
get_date;
msg_info "END ${this_script} at ${funct_result}";
job_stop "${this_script}"




