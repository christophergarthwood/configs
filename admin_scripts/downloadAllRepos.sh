#!/usr/bin/bash

##########################################################
#- Application Variables (change as needed)
##########################################################
if [ -f "${HOME}/.bashrc_keys" ];
then
    #get the hidden details
    echo "Sourcing your ~/.bashrc_keys to obtain your Personal Access Token";
    source "${HOME}/.bashrc_keys";
else
    echo "";
    echo "ERROR: This script assumes the existence of a ~/.bashrc_keys file.";
    echo "Preference is to keep your details hidden from prying eyes.";
    echo "You need a GIT_AUTHOR_NAME, GIT_URL, and PAT";
    echo "Aborting execution...";
    exit 1;
fi


#additional Git Repository details
export GITLAB_GROUPS=( "navo-se" );
#must be lowercase with dashed regarless of what you see in an output
export GITLAB_REPOS=( "erddap-mcp" "erddapy" "langgraph-multi-agent-workflow" "wade-docs" "inference-engines" "open-webui" );
export BRANCH="main";
export SHALLOW_DEPTH=100;
export DAYS_AGO=$(date -d "30 days ago" +%Y-%m-%d)

#establish where you are on the OS so you can return
this_script=$(basename "${0}");
readonly this_script;
script_dir=$( cd "$( dirname "${0}" )" && pwd );
readonly script_dir;
ISO8601=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
typeset d;

# Create temporary directory will be removed after job runs
export TEMP_DIR=$(mktemp -d)
export OUTPUT_FILE="${TEMP_DIR}/log.txt";

echo "BEGIN";
echo "";
echo "================================================";
echo "Git Repository Downloader";
echo "================================================";
echo "GIT_AUTHOR_NAME: ${GIT_AUTHOR_NAME}";
echo "        GIT_URL: ${GIT_URL}";
echo "  GITLAB_GROUPS: ${GITLAB_GROUPS}";
echo "   GITLAB_REPOS: ${GITLAB_REPOS[@]}";
echo "         BRANCH: ${BRANCH}";


##########################################################
#- Basic Error checking
##########################################################
if [[ -v GIT_TOKEN ]]; then
  echo "...GIT_TOKEN is set, assigning to GITLAB_TOKEN";
  export GITLAB_TOKEN="${GIT_TOKEN}";
elif [[ -v NRL_REPO_PAT ]]; then
  echo "...NRL_REPO_PAT is set, assigning to GITLAB_TOKEN";
  export GITLAB_TOKEN=${NRL_REPO_PAT};
elif [[ -v WEBGITMIL_PAT ]]; then
  echo "...WEBGITMIL_PAT is set, assigning to GITLAB_TOKEN";
  export GITLAB_TOKEN=${WEBGITMIL_PAT};
else
  echo "...You do not have a PAT set, aborting execution without your PAT you can't interact with the repository.";
  echo "...Ensure an environment variable entitled GIT_TOKEN is assigned your PAT and that var is in ~/.bashrc_keys.";
  echo "ERROR: Aborting execution.";
  exit 1;
fi

echo "================================================";
echo "";

##########################################################
#- Iterate through each group gathering the repositories below it
##########################################################
for the_group in "${GITLAB_GROUPS[@]}"
do
    PROJECT_ID="${the_group}";
    export PROJECT_ID;
    # URL encode the project ID if it contains slashes
    PROJECT_ID_ENCODED=$(echo "$the_group" | sed 's/\//%2F/g');
    echo "Processing ${PROJECT_ID}";
    echo ""
    if ! [ -d "${HOME}/${the_group}" ]; 
    then 
       echo "WARNING: (${HOME}/${the_group}) is not a directory, creating...";
       mkdir -p "${HOME}/${the_group}";
       status=$?;
       if [ "${status}" -ne 0 ];
       then
		  echo "ERROR: Unable to mkdir -p ${HOME}/${the_group}, check perms.";
          echo "ERROR: Aborting operation...";
          exit 1;
       fi
    fi

    #Fetch all repositories in the project (paginated)
    page=1
    per_page=100
    has_more=true

    ##########################################################
    #- See if this group has any repositories
    ##########################################################
    echo "...fetching repository list from GitLab API..."

    rm -rf ${the_group}/repos_list.json;
    while [ "$has_more" = true ]; do
      echo "......fetching page $page..."
        # Check if response is Forbidden, just quit
        #query_url="$GIT_URL/api/v4/groups/$PROJECT_ID_ENCODED/projects?per_page=$per_page&page=$page&include_subgroups=true";
        #status_code=$(curl -s -o /dev/null -w '%{http_code}' --header "PRIVATE-TOKEN: $GITLAB_TOKEN"  "$query_url");
        query_url="$GIT_URL/api/v4/projects/?per_page=$per_page&page=$page";
        status_code=$(curl -s -o /dev/null -w '%{http_code}' --header "PRIVATE-TOKEN: $GITLAB_TOKEN"  "$query_url");
	#echo "$query_url";
	#echo "$RESPONSE_BODY";

	
        if [[ "$status_code" -eq 403 ]]; then
            echo "ERROR: Got 403 Forbidden from $query_url";
            exit 1;
        elif [[ "$status_code" -eq 404 ]]; then
            echo "ERROR: Got 404 Forbidden from $query_url";
            exit 1;
	fi

        response=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "${query_url}");
        #"$GIT_URL/api/v4/groups/$PROJECT_ID_ENCODED/projects?per_page=$per_page&page=$page&include_subgroups=true")

        # Check if response is empty or contains an error
		if [ -z "$response" ] || echo "$response" | grep -q "\"message\""; then
			if [ $page -eq 1 ]; then
				echo "Error: Unable to fetch projects. Response code returned: $response";
				exit 1;
			else
				has_more=false;
				break;
			fi
		fi
    
		# Check if we got any results
		repo_count=$(echo "$response" | grep -o '"id":' | wc -l)
    
		if [ "$repo_count" -eq 0 ]; then
			has_more=false;
		else
			# Save repository information to a file
			echo "$response" >> "${HOME}/${the_group}/repos_list.json";
			page=$((page + 1));
		fi
	done

    echo "...processing repositories within project";

    # Parse the JSON and extract repository information
    repos=$(cat ${HOME}/${the_group}/repos_list.json 2>/dev/null || echo "[]")
	repo_count=$(cat ${HOME}/${the_group}/repos_list.json | grep -o '"id":' | wc -l)

	if [ "$repo_count" -eq 0 ]; then
		echo "WARNING: No repositories found in this project."
		echo "ERROR: This might be because:"
		echo "ERROR:  1. The project/group is empty"
		echo "ERROR:  2. The project ID is incorrect"
		echo "ERROR:  3. The access token doesn't have sufficient permissions"
		echo "ERROR: Aborting operation...";
		exit 1
	fi

	echo "...confirmed $repo_count repositories"

    ##########################################################
	#- Extract and clone each repository
    ##########################################################
	counter=0
	echo "$repos" | grep -o '"http_url_to_repo":"[^"]*"' | cut -d'"' -f4 | while read -r http_url; do
        # skip empty lines if desired
        [[ -z "$http_url" ]] && continue

		counter=$((counter + 1))
    
		# Extract repository name from URL
		repo_name=$(basename "$http_url" .git)
		repo_sname=$(basename "$http_url")
		repo_dir_name=$(echo "$http_url" | cut -d":" -f2 |cut -d"/" -f4- | awk '{for(i=length($0);i>0;i--) printf "%s", substr($0,i,1); print ""}' | cut -d"." -f2- | cut -d"/" -f2- | awk '{for(i=length($0);i>0;i--) printf "%s", substr($0,i,1); print ""}' );

        if [ "${#GITLAB_REPOS[@]}" -gt 1 ]; then
			if [[ " ${GITLAB_REPOS[*]} " != *" $repo_name "* ]]; then
			  continue;
			fi
        fi
		echo "...[$counter/$repo_count] Cloning: $repo_name"
        actual_url=$(echo ${http_url} | cut -d":" -f2- | cut -c3-)

		#echo "     HTTP_URL:${http_url}";
        #echo "   ACTUAL_URL:${actual_url}";
		#echo "    REPO_NAME:${repo_name}";
		#echo "   REPO_SNAME:${repo_sname}";
		#echo "REPO_DIR_NAME:${repo_dir_name}";

        echo "......checking existence of ${HOME}/${repo_dir_name}/${repo_name}/.git";
        if [ -d "${HOME}/${repo_dir_name}/${repo_name}/.git" ];
        then
            echo "......cd into $HOME/${repo_dir_name}/${repo_name} and fetch --all";
            cd "${HOME}/${repo_dir_name}/${repo_name}" > /dev/null 2>&1 || echo "ERROR: Failed to change directories, cannot fetch -all repo information, aborting..." || exit 1;
            git fetch --all;
            status=$?;
            if [ "${status}" -eq 0 ]; 
            then
                echo ".........✓ Successfully fetch-all on $repo_name"
            else
                echo ".........✗ Failed to fetch-all on $repo_name"
            fi
        else
            echo "......clone the repository";
            if [ ! -d "${repo_dir_name}" ];then
                echo ".........mkdir -p ${HOME}/${repo_dir_name}";
                mkdir -p "${HOME}/${repo_dir_name}";
                status=$?;
                if [ "${status}" -eq 0 ]; 
                then
                    echo ".........✓ Successfully created $repo_dir_name"
                else
                    echo ".........✗ Failed to create $repo_dir_name"
                    echo "ERROR: Unable to mkdir -p $HOME/${repo_dir_name}, check perms.";
                    echo "ERROR: Aborting operation...";
                    exit 1;
                fi
            fi

            cd "${HOME}/${repo_dir_name}" > /dev/null 2>&1 || echo "ERROR: Failed to change directories, cannot git clone to the project location, aborting..." || exit 1;
            #pwd;

            if git clone "https://${GIT_AUTHOR_NAME}:${GITLAB_TOKEN}@$actual_url" 2>&1; 
            then
                echo ".........✓ Successfully cloned $repo_name"
            else
                echo ".........✗ Failed to clone $repo_name via HTTPS"
            fi
        fi

        ##########################################################
	    #- Obtain log output and save with the directory.
        ##########################################################
        if ! [ -d "${HOME}/${repo_dir_name}/${repo_name}" ]; 
        then 
            echo "ERROR: (${HOME}/${repo_dir_name}/${repo_name}) is not a directory, perhaps the git clone failed, aborting executing...";
        fi
        echo "......obtained log output from the repository ${HOME}/${repo_dir_name}/${repo_name}";
        cd "${HOME}/${repo_dir_name}/${repo_name}" > /dev/null 2>&1 || echo "WARNING: Failed to change directories, cannot git log, continuing..." || continue;

        git --no-pager log --since="${DAYS_AGO}"  --pretty=format:'%H\|%an\|%ae\|%ad\|%s\|\$\{REMOTE_URL\}' --date=iso >> "${OUTPUT_FILE}";
        status=$?;
        if [ "${status}" -eq 0 ];
		then
			echo ".........✓ Successfully obtained log info from $repo_name"
		else
			echo ".........✗ Failed to get log output from $repo_name, perhaps you didn't commit here."
		fi

        cp "${OUTPUT_FILE}" "./${repo_name}_git.log"
        echo "......log output saved to:${HOME}/${repo_dir_name}/${repo_name}/${repo_name}_git.log";

        cd "${script_dir}" > /dev/null 2>&1 || echo "ERROR: Failed to change directories (${script_dir}), output will be mangled and project structure will be botched, aborting..." || exit 1;
		echo ""

        if [ "${counter}" -gt 9 ];
        then
            exit 1;
       fi
	done #looping through repos for this group
done #looping through groups

echo " ";
echo " ";
echo " ";
echo "Download complete!";
echo "END";

