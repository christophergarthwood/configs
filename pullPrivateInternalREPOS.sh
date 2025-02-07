#!/usr/bin/bash

#this code is to support using GitHub Command Line Utilities (gh) and Internal/Private repositories which require an additional layer of security.

#repository names pulled from Repo->Code->HTTPS and remove the https:// at the start of the repo
export repos=(code.fs.usda.gov/forest-service/CIO_CDO_Collaboration.git code.fs.usda.gov/forest-service/CIO_DataCalls.git)


#source RC's
source ~/.bashrc

#create a GitHub Personal Access Token (PAT) via https://code.fs.usda.gov/settings/tokens using the Tokens (classic), remember this value and store it somewhere.
export PAT="${GITHUB_PAT}"

#find your USERNAME from your profile in code.fs.usda.gov
#export USERNAME="Christopher-Wood3"
#Now assumes set in .bashrc_mine

for repo in ${repos[@]}
do
  echo "Cloning ${repo}"
  #Reference: https://stackoverflow.com/questions/2505096/clone-a-private-repository-github
  git clone https://"${USERNAME}":"${PAT}"@${repo} || echo "WARNING - Failed to perform the git clone.";
  echo "...git clone https://${USERNAME}:${PAT}@${repo}";

done
