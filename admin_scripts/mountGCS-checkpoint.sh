#!/usr/bin/bash

#Add this to your .bashrc or equivalent so you can `source ~/.bashrc` and receive the benefit of gs-fuse anytime.
#References:
#    https://cloud.google.com/blog/topics/developers-practitioners/cloud-storage-file-system-vertex-ai-workbench-notebooks/
#    https://cloud.google.com/storage/docs/cloud-storage-fuse/cli-options

export EXE_GCSFUSE="/usr/bin/gcsfuse";
export GCS_BUCKET="general-335aun";
export GCS_MOUNT_POINT="/home/jupyter/projects/gcs";

cd ~/ # This should take you to /home/jupyter/
if ! [ -f "${EXE_GCSFUSE}" ];
then
  echo "FAILURE, ${EXE_GCSFUSE} not found, aborting..."
  exit 1;
fi

#is the mount point present?
if ! [ -d "${GCS_MOUNT_POINT}" ];
then
    # Create a folder that will be used as a mount point
    status=$( mkdir -p "${GCS_MOUNT_POINT}" );

    #was the directory creation successful?
    if [ "${status}" != "0" ];
    then
      echo "ERROR: Status of ${status} returned.  Investigate attempts to create the (${GCS_MOUNT_POINT}) directory.";
      exit 1;
    fi
fi

#mount the file system
status=$( gcsfuse --implicit-dirs --rename-dir-limit=100 --max-conns-per-host=100 "${GCS_BUCKET}" "${GCS_MOUNT_POINT}" );
#status=$( ${EXE_GCSFUSE} "${GCS_BUCKET}" "${GCS_MOUNT_POINT}" );
echo "Mount Status of:";
echo "------------------------------------------------";
echo " ${status}";
echo "------------------------------------------------";

#ls -alFh "${GCS_MOUNT_POINT}"
