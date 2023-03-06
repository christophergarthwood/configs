#!/bin/bash

utility="us.navo.hpc.mil"
gordon="gordon.navo.hpc.mil"
conrad="conrad.navo.hpc.mil"
#MACHINE_NAMES=('conrad.navo.hpc.mil' 'gordon.navo.hpc.mil' 'us.navo.hpc.mil' )
target_users=( "cwood" "jcm" )
target_paths=( "/home/cwood" "/home/jcm/user_dirs/cwood" )
target_machine=( "$conrad" "$gordon" "$utility" ) 
target_loc=( "/p" "/u" )
#drive=""
#path=""

whichPath() {
  if [ "$1" == "${target_users[1]}" ];
  then
	  path="${target_paths[1]}"
  else
	  path="${target_paths[0]}"
  fi
}

whichDrive() {
  if [ "$1" == "$utility" ];
  then
	  drive="${target_loc[1]}"
  else
	  drive="${target_loc[0]}"
  fi
}

current_host=$(hostname | cut -d- -f1)
current_user=$(whoami)
whichPath "$current_user"
current_path="$path"
whichDrive "$current_host"
current_drive="$drive"
resultant=""
for user in "${target_users[@]}"
do
  whichPath "$user"
  for host in "${target_machine[@]}"
  do
	  if [ "$current_host" != "$host" ];
	  then
		whichDrive "$host"
        resultant=$resultant"rsync -avz $current_drive$current_path/Documents/ $user@$host:$drive$path/Documents/;"
      fi
  done
done
echo $resultant
