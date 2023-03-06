# VARIABLES #
#############################################################
#  \ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____/ ___| 
#   \ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _| \___ \ 
#    \ V / ___ \|  _ < | | / ___ \| |_) | |___| |___ ___) |
#     \_/_/   \_\_| \_\___/_/   \_\____/|_____|_____|____/ 
#############################################################

export GIT_EDITOR=vim;
export GIT_AUTHOR_NAME="christopher.wood";
export GIT_AUTHOR_EMAIL="christopher.wood@nrlssc.navy.mil";
export GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME};
export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL};

export LINUX="Linux";
export WINDOWS="MINGW64_NT-10.0";
export MAC="Darwin";
export platform="";

export the_git_user="christopher.wood";
#export the_git_protocol="ssh";
#export the_git_repo="${the_git_protocol}://git@aronnax.nrlssc.navy.mil/";
export the_git_repo="git@aronnax.nrlssc.navy.mil:";


# FUNCTIONS #
#############################################################
#    |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
#    | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
#    |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
#    |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/
#############################################################
function determine_platform() {
    platform=$(uname -a | cut -d' ' -f1)
}

function set_vars() {

  if [ "${platform}" == "${LINUX}" ];
  then
    export PLATFORM_HOME=$HOME/Documents/SOURCE
    export PLATFORM_REMOTE_HOME=/u/yamm/cwood
  elif [ "${platform}" == "${WINDOWS}" ];
  then
    export PLATFORM_HOME=.\
    export PLATFORM_REMOTE_HOME=Z:
  elif [ "${platform}" == "${MAC}" ];
  then
    export PLATFORM_HOME=$HOME/Documents/SOURCE
    export PLATFORM_REMOTE_HOME=/u/yamm/cwood
  else
    echo "Aborting execution, platform not recognized.";
    exit 1;
  fi
}

function technical_docs() {
echo "Syncing (mirror) from ${PLATFORM_REMOTE_HOME}\\docs\\technical to ${PLATFORM_HOME}\\technical"
if [ -d "${PLATFORM_HOME}/docs/technical}" ];
then
mkdir -p "${PLATFORM_HOME}/docs/technical"
    fi

    if [ "${platform}" == "${LINUX}" ] || [ "${platform}" == "${MAC}" ];
    then
      results=$($command_rsync -avz --progress "${PLATFORM_REMOTE_HOME}"/docs/technical/ "${PLATFORM_HOME}"/docs/technical/ | tail -2)
      echo "   ${results} files processed with rsync."
    elif [ "${platform}" == "${WINDOWS}" ];
    then
      robocopy "${PLATFORM_REMOTE_HOME}"\\docs\\technical\\ "${PLATFORM_HOME}"\\docs\\technical\\ //MIR
    else
      echo "Aborting execution, platform not recognized.";
      exit 1;
    fi
}

function data() {
echo "Syncing (mirror) from ${PLATFORM_REMOTE_HOME}\\data to ${PLATFORM_HOME}\\data"
if [ -d "${PLATFORM_HOME}/data}" ];
then
        mkdir -p "${PLATFORM_HOME}/data"
    fi

    if [ "${platform}" == "${LINUX}" ] || [ "${platform}" == "${MAC}" ];
    then
      echo "No data will be synced to Linux as it is resident at NRL and has network access."
      #results=$(rsync -avz --progress "${PLATFORM_REMOTE_HOME}"/data/ "${PLATFORM_HOME}"/data/ | tail -2)
      #echo "   ${results} files processed with rsync."
    elif [ "${platform}" == "${WINDOWS}" ];
    then
      robocopy "${PLATFORM_REMOTE_HOME}"\\data\\ "${PLATFORM_HOME}"\\data\\ //MIR
    else
      echo "Aborting execution, platform not recognized.";
      exit 1;
    fi

}

function git_repos() {

    repo_root="${1}"
    repo_urls="${2}"

    echo "Repository root: ${repo_root}"
    echo "   urls: ${repo_urls[@]}"
    echo " "

for repo in ${repo_urls[@]}
    do
IFS=. read -r git_name git_extension <<EOF
        ${repo}
EOF
git_repository_name=$(echo -e "${git_name}" | tr -d '[:space:]');
        echo "Processing ${git_repository_name}";
        echo "...${repo_root}/${repo}";
	if [ -d "${PLATFORM_HOME}/${git_repository_name}" ];
	then
	    if [ "${platform}" == "${LINUX}" ] || [ "${platform}" == "${MAC}" ];
	    then
		thePath="${PLATFORM_HOME}/${git_repository_name}";
	    elif [ "${platform}" == "${WINDOWS}" ];
	    then
		thePath="${PLATFORM_HOME}\\${git_repository_name}";
	    fi

	    cd "${thePath}"
	    echo "...cd to $(pwd)"
	    if ! [ -d .git ];
	    then
		echo "......no .git file found, backing up and cloning."
		cd ..
		echo "...$command_git clone ${repo_root}/${repo}.git";
		$command_git clone "${repo_root}/${repo}.git"
		status=$?
		if [ "${status}" -ne 0 ];
		then
		    echo "WARNING: initial clone failed with status code of (${status})".
		    echo " ";
		fi
	    else
		echo "...performing pull for each branch.";
		if [ `ls -1 | wc -l` -eq 0 ];
		then
		    echo "...$command_git reset --hard";
		    $command_git reset --hard;
		    status=$?
		    if [ "${status}" -ne 0 ];
		    then
			echo "WARNING: reset --hard failed with status code of (${status})".
			echo " ";
		    fi
		fi
		echo "......$command_git fetch --all";
		$command_git fetch --all;
		status=$?
		if [ "${status}" -ne 0 ];
		then
		    echo "WARNING: fetch --all failed with status code of (${status})".
		    echo " ";
		fi
		echo "...$command_git checkout master";
		$command_git checkout master;
		status=$?
		if [ "${status}" -ne 0 ];
		then
		    echo "WARNING: checkout master failed with status code of (${status})".
		    echo "...trying $command_git checkout main";
		    $command_git checkout main;
		    echo " ";
		fi
	    fi
	    cd ${PLATFORM_HOME};
	else
	    echo "...no repository folder found, performing clone.";
	    echo "......$command_git clone ${repo_root}/${repo}.git";
	    $command_git clone "${repo_root}/${repo}.git" ;
	    status=$?
	    if [ "${status}" -ne 0 ];
	    then
		echo "WARNING: clone failed with status code of (${status})".
		echo " ";

	    fi
	fi

    #do a pull just to make sure you're up to date, don't worry about response.
    thePath="${PLATFORM_HOME}/${git_repository_name}";
    cd "${thePath}" || echo "ERROR: Cannot cd into ${thePath}...";
    $command_git pull
    cd ${PLATFORM_HOME};

	if [ -d "${PLATFORM_HOME}/${git_repository_name}" ];
	then
	    echo "SUCCESS, successfully extracted and updated ${git_repository_name}";
	else
	    echo "FAIL, unsuccessfully extracted and updated ${git_repository_name}";
	fi
	echo "======================================================= ";
	echo " ";
	echo " ";
done
}

# MAIN #
#############################################################
#       |  \/  |  / \  |_ _| \ | |
#       | |\/| | / _ \  | ||  \| |
#       | |  | |/ ___ \ | || |\  |
#       |_|  |_/_/   \_\___|_| \_|
#############################################################
determine_platform
echo "Platform identifed as ${platform}."
if [ "${platform}"=="${LINUX}" ];
then
    export command_rsync="/usr/bin/rsync";
    export command_git="/usr/bin/git";
elif [ "${platform}"=="${MAC}" ];
then
    export command_rsync="/usr/bin/rsync";
    export command_git="/opt/homebrew/bin/git";
else
    echo "No commands set for Windows.";
fi
set_vars
#technical_docs
#data

#NRL
export repo_root="${the_git_repo}/nrl7331";
export repo_urls=( 7331_CALs 7331_DEVs 7331_website jbooks fldspec_shell bum );
git_repos ${repo_root} ${repo_urls};

#OFM
export repo_root="${the_git_repo}/ofm";
export repo_urls=( optical-forecast-model );
git_repos ${repo_root} ${repo_urls};

#AOPS
export repo_root="${the_git_repo}/aops";
export repo_urls=( aops-v16 aops-v21 );
git_repos ${repo_root} ${repo_urls};

#GOPS
export repo_root="${the_git_repo}/gops";
export repo_urls=( visor-gops-scripts visor_gops_parser v23 visor_ncodaqc_optics visor_ncodavar_optics );
git_repos ${repo_root} ${repo_urls};

#AI/ML
export repo_root="${the_git_repo}/ai_ml";
export repo_urls=( aec_multivariate intro );
git_repos ${repo_root} ${repo_urls};

#RECON
export repo_root="${the_git_repo}/recon";
export repo_urls=( recon-machine-learning );
git_repos ${repo_root} ${repo_urls};

#Personal
export repo_root="${the_git_repo}/christopher.wood";
export repo_urls=( myconfigs mycode devtools);
git_repos ${repo_root} ${repo_urls}
