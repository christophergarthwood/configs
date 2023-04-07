#!/bin/bash

####################################################################
#- Script designed to support GitHub Codespaces.  Creates symbolic
#- links of your .rc's and checks to see if conda is installed, if 
#- so basic conda components are installed.
####################################################################

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
echo "Install dotfiles -> Establishing variables.";
export CONDA_EXE="";
CONDA_EXE=$(which conda);
export CONDA_DIR="/opt/conda";
export THE_RC="~/.bashrc";
export ALTERNATE_RC="/workspaces/.codespaces/.persistedshare/dotfiles/.bashrc";
export THE_APP="conda";

#maybe let I/O catch up for the symlink build?
sleep 5


if [ -d "${CONDA_DIR}" ];
then
	echo "Install dotfiles -> searching for ${THE_RC}";
	if [ -f "${THE_RC}" ];
	then
		echo "Install dotfiles -> found ${THE_RC}, updating for conda.";
		echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" >> "${THE_RC}";
		${CONDA_EXE} config --set report_errors false;
		${CONDA_EXE} init bash;
	else
	    echo "Install dotfiles -> Failed to init the bash for conda as ~/.bashrc was not there.";
	    echo "Install dotfiles -> ...updating your bashrc directly.";
	    if [ -f "${ALTERNATE_RC}" ];
	    then
		echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" >> "${ALTERNATE_RC}";
		echo "${THE_APP} activate base" >> "${ALTERNATE_RC}";
	    fi
	    echo "Install dotfiles -> updated ${ALTERNATE_RC}.";
	fi
else
    echo "No Anaconda environment detected, bashrc will not be updated.";
fi


