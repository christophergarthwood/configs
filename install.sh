#!/bin/bash

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks

#now provide some conda inputs (checking for existence)

export CONDA_EXE="";
CONDA_EXE=$(which conda);
export CONDA_DIR="/opt/conda";
export THE_RC="~/.bashrc";
export THE_APP="conda";

${CONDA_EXE} config --set report_errors false
${CONDA_EXE} init bash 

status=$?
if [ "${status}" -ne 0 ];
then
    echo "Failed to init the bash for conda.";
    echo "...updating your bashrc directly.";
    if [ -f "${THE_RC}" ];
    then
	echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" >> "${THE_RC}";
	echo "${THE_APP} activate base" >> "${THE_RC}";
    fi
fi


