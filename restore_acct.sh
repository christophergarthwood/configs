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
export BIN_FOLDER="/home/jupyter/bin";
export TARGET_FOLDER="/home/jupyter/projects";
export DATA_FOLDER="${TARGET_FOLDER}/data";
export WORK_FOLDER="${TARGET_FOLDER}/work";
export TARGET_BUCKET="general-335aun";
export STATE_DIR="./";
#arg_incoming_region passed by way of arguments
GLOBAL_DTG=${GLOBAL_DTG};
GLOBAL_YMD=${GLOBAL_YMD};

repos=( git@github.com:christophergarthwood/jbooks.git )
repos_names=( sample_jbooks )

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
validate () {

    #==============================================================================="
    #-- Validate conditions for success
    #==============================================================================="
    #if [ ! -f "${BIOCAST_EXE}" ];
    #then
    #    msg_emerg "${this_script} failed.  ${BIOCAST_EXE} does not exist, cannot proceed for this run.";
    #fi
    msg_info "Validating install."; 
    the_dirs=( ${BIN_FOLDER} ${DATA_FOLDER} ${WORK_FOLDER} )
    for the_dir in ${the_dirs[@]}
    do
        if [ -d "${the_dir}" ]; then
            msg_debug "...success, ${the_dir} checks out.";
        else
            msg_debug "...FAILURE, ${the_dir} is not present and might be an issue.";
        fi
    done

    the_rcs=( .bashrc .bashrc_mine .bashrc_keys .bashrc_alias .bashrc_machines .bash_profile .bash_login .inputrc .gitignore )
    for the_rc in ${the_rcs[@]}
    do
        if [ -f "/home/jupyter/${the_rc}" ]; then
            msg_debug "...success, /home/jupyter/${the_rc} is present.";
        else
            msg_debug "...FAILURE, /home/jupyter/${the_rc} is not present and might be an issue.";
        fi
    done

    the_scripts=( ${BIN_FOLDER}/mountGCS-checkpoint.sh ${BIN_FOLDER}/setGitDetails.sh ${BIN_FOLDER}/pullPrivateInternalREPOS.sh )
    for the_script in ${the_scripts[@]}
    do
        if [ -f "${BIN_FOLDER}/${the_script}" ]; then
            msg_debug "...success, ${BIN_FOLDER}/${the_script} is present.";
        else
            msg_debug "...FAILURE, ${BIN_FOLDER}/${the_script} is not present and might be an issue.";
        fi
    done

}

# @description This function "prepares" the necessary files or functions that are needed
# for this task.  Prepping might be copying file(s) or sleeping for 30 seconds while 
# waiting for another process to finish.
#
# @noargs
#
# @see main
prep () {


    #==============================================================================="
    #-- used to "prepare" whatever is necessary prior to run (full blown execution).
    #==============================================================================="
    banner "prep";

    msg_info "Making strategic folders:"
    mkdir -p "${BIN_FOLDER}";
    chmod ugo+rx "${BIN_FOLDER}";
    msg_debug "...${BIN_FOLDER} created and perms updated.";

    msg_info "Setting up the Google Cloud Fuse for your Cloud Storage";
    msg_debug "...downloading GCS Mount script.";
    /usr/bin/wget --no-check-certificate https://code.fs.usda.gov/raw/forest-service/CIO_CDO_Collaboration/main/shared/mountGCS-checkpoint.sh?token=GHSAT0AAAAAAAAAYYII4U3XCJ5QLWQPM6EUZ5GM6CQ -O ${BIN_FOLDER}/mountGCS-checkpoint.sh
    chmod ugo+x "${BIN_FOLDER}/mountGCS-checkpooint.sh";
    msg_debug "...~/bin/mountGCS-checkpoint.sh created and perms updated.";

    msg_info "Creating initial folders."
    mkdir -p "${DATA_FOLDER}";
    mkdir -p "${WORK_FOLDER}";
    chmod -R u+rwx "${TARGET_FOLDER}"
    msg_debug "...${TARGET_FOLDER} created and perms updated.";
    msg_debug "";

    msg_info "Sample rc's";
    mkdir -p /home/jupyter/temp
    cd /home/jupyter/temp
    git clone https://github.com/christophergarthwood/configs
    echo "Downloaded a sample set of configuration files, copying *.rc's to your /home/jupyter, modify as you see fit."
    rcs=( .bashrc .bashrc_mine .bashrc_keys .bashrc_alias .bashrc_machines .bash_profile .bash_login .inputrc .gitignore )
    for rc in ${rcs[@]}
    do
        msg_debug "...copying ${rc} to ~"
        cp "/home/jupyter/temp/configs/${rc}" "/home/jupyter/"
    done

    msg_info "Sourcing your /home/jupyter/.bashrc"
    source /home/jupyter/.bashrc

}

# @description This function represents the actual execution of the task's purpose.
# This function is where the actual work is done.
#
# @noargs
#
# @see main
run () {

    #==============================================================================="
    #-- Execute main mechanism
    #==============================================================================="
    banner "run";
    export OUT_DATE="";
    get_ISO8601;
    OUT_DATE="${funct_result}";

    msg_debug "...copying useful scripts to ~/bin";
    cp /home/jupyter/temp/configs/setGitDetails.sh "${BIN_FOLDER}/"; 
    cp /home/jupyter/temp/configs/pullPrivateInternalREPOS.sh "${BIN_FOLDER}/"; 

    msg_info "Creating repositories in ${WORK_FOLDER}"
    export COUNTER=0
    for repo in "${repos[@]}"
    do
      msg_debug "git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]}"
      git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]}
      (( COUNTER++ ))
    done

    #useful commands to remember for transfer data without gcsfuse
    #msg_debug "gsutil of target bucket to local machine..."
    #msg_debug "...gsutil -m cp -r gs://${TARGET_BUCKET}/ ${DATA_FOLDER}"
    #gsutil -m cp -r "gs://${TARGET_BUCKET}/" "${DATA_FOLDER}"

}

# @description This function represents the final tasks performed after a "run".
# Migration of files, tarball setup, or cleaning of log files are examples of what
# might be run during this task.
#
# @noargs
#
# @see main
post () {

    #==============================================================================="
    #-- Perform clean-up functions appropriate for biocast completion
    #==============================================================================="
    banner "post";

    msg_info "Git Setup"
    msg_debug "Ensure you update the GIT_* environment variables and then run ~/bin/setGitDetails.sh";
    msg_debug "Calling ~/bin/setGitDetails.sh after updating your ~/.bashrc_mine will align git to your account.";
    echo " "

    msg_info "GitHub PAT";
    msg_debug "...obtain a GIT PAT from https://code.fs.usda.gov/settings/tokens and update ~/.bashrc_keys";
    msg_debug "...then `source ~/.bashrc` to include the keys into your environment.";

    msg_info "Setup your REPO";
    msg_debug "...perform a git clone of the CIO_CDO_Collaboration Repo.";
    msg_debug "...see ~/bin/pullPrivateInternalREPOS.sh and execute aftger reviewing.";
    msg_debug "...Check for the repos var on line 6 and USERNAME on line 12, adjust accordingly.";
    msg_debug "...If you don't take this step good luck trying to download the repo on your own.";
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
#job_start "${this_script}"

#==============================================================================="
#-- EXECUTE"
#==============================================================================="
msg_info "Begin"

prep
validate
run
post

end_time=$(date +%s);
msg_info "Execution time was $((end_time - start_time)) s.";
get_date;
msg_info "END ${this_script} at ${funct_result}";
#job_stop "${this_script}"
