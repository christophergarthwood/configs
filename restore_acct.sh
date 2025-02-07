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

repos=( https://github.com/christophergarthwood/jbooks.git )
repos_names=( sample_jbooks )

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
        echo "${output_str}";
    else
        echo "=======================================================================";
    fi
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
#############################################################
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

#############################################################
# @description This function should validate all requirements for the execution
# of the task prior to attempting the task.  This might include checking for existing
# directories, required inputs, or executables.
#
# @noargs
#
# @see main
#############################################################
validate () {

    #==============================================================================="
    #-- Validate conditions for success
    #==============================================================================="
    echo " ";
    echo " ";
    banner "prep";
    echo "INFO:Validating install."; 
    the_dirs=( ${BIN_FOLDER} ${DATA_FOLDER} ${WORK_FOLDER} )
    for the_dir in ${the_dirs[@]}
    do
        if [ -d "${the_dir}" ]; then
            echo "DEBUG: ...success, ${the_dir} checks out.";
        else
            echo "DEBUG: ...FAILURE, ${the_dir} is not present and might be an issue.";
        fi
    done

    the_rcs=( .bashrc .bashrc_mine .bashrc_keys .bashrc_alias .bashrc_machines .bash_profile .bash_logout .inputrc .gitignore )
    for the_rc in ${the_rcs[@]}
    do
        if [ -f "/home/jupyter/${the_rc}" ]; then
            echo "DEBUG:...success, /home/jupyter/${the_rc} is present.";
        else
            echo "DEBUG:...FAILURE, /home/jupyter/${the_rc} is not present and might be an issue.";
        fi
    done

    the_scripts=( ${BIN_FOLDER}/mountGCS-checkpoint.sh ${BIN_FOLDER}/setGitDetails.sh ${BIN_FOLDER}/pullPrivateInternalREPOS.sh )
    for the_script in ${the_scripts[@]}
    do
        if [ -f "${the_script}" ]; then
            echo "DEBUG: ...success, ${the_script} is present.";
        else
            echo "DEBUG: ...FAILURE, ${the_script} is not present and might be an issue.";
        fi
    done

}

#############################################################
# @description This function "prepares" the necessary files or functions that are needed
# for this task.  Prepping might be copying file(s) or sleeping for 30 seconds while 
# waiting for another process to finish.
#
# @noargs
#
# @see main
#############################################################
prep () {


    #==============================================================================="
    #-- used to "prepare" whatever is necessary prior to run (full blown execution).
    #==============================================================================="
    echo " ";
    banner "prep";
    echo "INFO:  Making strategic folders:"
    mkdir -p "${BIN_FOLDER}" || echo "WARNING:...mkdir failed."
    chmod ugo+rx "${BIN_FOLDER}" || echo "WARNING:...chmod failed.";
    echo "DEBUG: ...${BIN_FOLDER} created and perms updated.";
    mkdir -p "${DATA_FOLDER}" || echo "WARNING:...mkdir failed.";
    mkdir -p "${WORK_FOLDER}" || echo "WARNING:...mkdir failed.";
    chmod -R u+rwx "${TARGET_FOLDER}" || echo "WARNING:...chmod failed.";
    echo "DEBUG: ...${TARGET_FOLDER} created and perms updated.";
    echo " ";

    echo "INFO:  Setting up the Google Cloud Fuse for your Cloud Storage and example *.rc files.";
    mkdir -p /home/jupyter/temp || echo "WARNING:...mkdir failed.";
    cd /home/jupyter/temp
    git clone https://github.com/christophergarthwood/configs || echo "WARNING:...git clone of configs failed.";
    echo "DEBUG: ...~/bin/mountGCS-checkpoint.sh created and perms updated.";
    echo " ";

    echo "INFO:  Sample rc's";
    echo  "DEBUG: Downloaded a sample set of configuration files, copying *.rc's to your /home/jupyter, modify as you see fit."
    echo "DEBUG: ...backed up your original .bashrc to .old_bashrc";
    if [ -f /home/jupyter/.bashrc ]; then
        mv /home/jupyter/.bashrc /home/jupyter/.old_bashrc || echo "WARNING:...mv of .bashrc failed.";
    fi
    rcs=( .bashrc .bashrc_mine .bashrc_keys .bashrc_alias .bashrc_machines .bash_profile .bash_logout .inputrc .gitignore )
    for rc in ${rcs[@]}
    do
        echo "DEBUG: ...copying ${rc} to ~"
        cp "/home/jupyter/temp/configs/${rc}" "/home/jupyter/" || echo "WARNING:...cp of ${rc} failed.";
    done


}

#############################################################
# @description This function represents the actual execution of the task's purpose.
# This function is where the actual work is done.
#
# @noargs
#
# @see main
#############################################################
run () {

    #==============================================================================="
    #-- Execute main mechanism
    #==============================================================================="
    echo " ";
    banner "run";
    export OUT_DATE="";
    get_ISO8601;
    OUT_DATE="${funct_result}";

    echo "DEBUG: ...copying useful scripts to ~/bin";
    cp /home/jupyter/temp/configs/setGitDetails.sh "${BIN_FOLDER}/" || echo "WARNING:...cp of setGitDetails failed."; 
    cp /home/jupyter/temp/configs/pullPrivateInternalREPOS.sh "${BIN_FOLDER}/" || echo "WARNING:...cp of pullPrivateInternalREPOS failed."; 
    echo "DEBUG: ...copying the GCS Mount script.";
    cp /home/jupyter/temp/configs/mountGCS-checkpoint.sh "${BIN_FOLDER}/" || echo "WARNING:...copy failed."; 
    chmod ugo+x "${BIN_FOLDER}/*.sh" || echo "WARNING:...chmod failed.";

    echo "INFO:  Creating repositories in ${WORK_FOLDER}"
    export COUNTER=0
    for repo in "${repos[@]}"
    do
      echo "DEBUG: git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]}"
      git clone ${repo} ${WORK_FOLDER}/${repos_names[$COUNTER]} || echo "WARNING:...git clone of ${repos_name[$COUNTER]} failed.";
      (( COUNTER++ ))
    done

    #useful commands to remember for transfer data without gcsfuse
    #echo "DEBUG:gsutil of target bucket to local machine..."
    #echo "DEBUG:...gsutil -m cp -r gs://${TARGET_BUCKET}/ ${DATA_FOLDER}"
    #gsutil -m cp -r "gs://${TARGET_BUCKET}/" "${DATA_FOLDER}"

}

#############################################################
# @description This function represents the final tasks performed after a "run".
# Migration of files, tarball setup, or cleaning of log files are examples of what
# might be run during this task.
#
# @noargs
#
# @see main
#############################################################
post () {

    #==============================================================================="
    #-- Perform clean-up functions appropriate for biocast completion
    #==============================================================================="
    echo " "
    echo " "
    banner "post";

    echo "INFO:  Git Setup"
    echo "DEBUG: Ensure you update the GIT_* environment variables and then run ~/bin/setGitDetails.sh";
    echo "DEBUG: Calling ~/bin/setGitDetails.sh after updating your ~/.bashrc_mine will align git to your account.";
    echo " "

    echo "INFO:  GitHub PAT";
    echo "DEBUG: ...obtain a GIT PAT from https://code.fs.usda.gov/settings/tokens and update ~/.bashrc_keys";
    echo "DEBUG: ...then `source ~/.bashrc` to include the keys into your environment.";
    echo " "

    echo "INFO:  Setup your REPO";
    echo "DEBUG: ...perform a git clone of the CIO_CDO_Collaboration Repo.";
    echo "DEBUG: ...see ~/bin/pullPrivateInternalREPOS.sh and execute aftger reviewing.";
    echo "DEBUG: ...Check for the repos var on line 6 and USERNAME on line 12, adjust accordingly.";
    echo "DEBUG: ...If you don't take this step good luck trying to download the repo on your own.";
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
echo "INFO:BEGIN $this_script at $funct_result";

validate_arguments
if [ ! $execute ];
then
  error_msg="Minimal arguments were not supplied.  Check invoking program to ensure arguments were passed properly.";
  echo "ERROR:${error_msg}";
  exit 1;
fi

#==============================================================================="
#-- Source Configuration files passed in
#==============================================================================="

#==============================================================================="
#-- EXECUTE"
#==============================================================================="
echo "INFO:Begin"

prep
run
validate
post
echo "INFO:  Sourcing your /home/jupyter/.bashrc"
source /home/jupyter/.bashrc

end_time=$(date +%s);
echo "INFO:  Execution time was $((end_time - start_time)) s.";
get_date;
echo "INFO:  END ${this_script} at ${funct_result}";
