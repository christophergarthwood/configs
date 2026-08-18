#!/usr/bin/env bash

# Very basic script to list all GitLab projects an account has access to.
# Requirements:
#   - GIT_PAT environment variable set to a personal access token
#   - GIT_URL set to your GitLab base URL (e.g. https://gitlab.com or https://gitlab.example.com)

set -euo pipefail

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

if [[ -v GIT_TOKEN ]]; then
  echo "...GIT_TOKEN is set, assigning to GIT_PAT";
  export GIT_PAT="${GIT_TOKEN}";
elif [[ -v NRL_REPO_PAT ]]; then
  echo "...NRL_REPO_PAT is set, assigning to GIT_PAT";
  export GIT_PAT=${NRL_REPO_PAT};
elif [[ -v WEBGITMIL_PAT ]]; then
  echo "...WEBGITMIL_PAT is set, assigning to GIT_PAT";
  export GIT_PAT=${WEBGITMIL_PAT};
else
  echo "...You do not have a PAT set, aborting execution without your PAT you can't interact with the repository.";
  echo "...Ensure an environment variable entitled GIT_TOKEN is assigned your PAT and that var is in ~/.bashrc_keys.     ";
  echo "ERROR: Aborting execution.";
  exit 1;
fi

: "${GIT_PAT:?GIT_PAT is not set}"
: "${GIT_URL:?GIT_URL is not set}"

PER_PAGE=100
PAGE=1

echo "Listing projects accessible to the authenticated user..."
echo "GitLab: $GIT_URL"
echo

while :; do
  RESPONSE_HEADERS=$(mktemp)
  RESPONSE_BODY=$(mktemp)

  curl -sS \
    -H "PRIVATE-TOKEN: ${GIT_PAT}" \
    -D "$RESPONSE_HEADERS" \
    "${GIT_URL%/}/api/v4/projects?per_page=${PER_PAGE}&page=${PAGE}" \
    -o "$RESPONSE_BODY"

  # If body is empty, we're done
  if [[ ! -s "$RESPONSE_BODY" ]]; then
    rm -f "$RESPONSE_HEADERS" "$RESPONSE_BODY"
    break
  fi

  # Print project id and path with namespace
  #jq -r '.[] | "\(.id)\t\(.path_with_namespace)"' "$RESPONSE_BODY"
  jq -r '.[] | "\(.path_with_namespace)"' "$RESPONSE_BODY" | sort -u

  # Check if there is a next page via X-Next-Page header
  NEXT_PAGE=$(grep -i '^X-Next-Page:' "$RESPONSE_HEADERS" | awk '{print $2}' | tr -d '\r')

  rm -f "$RESPONSE_HEADERS" "$RESPONSE_BODY"

  if [[ -z "$NEXT_PAGE" ]]; then
    break
  fi

  PAGE="$NEXT_PAGE"
done
