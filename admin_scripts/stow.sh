#!/usr/bin/bash

# Target folder where links will go
TARGET_DIR="$HOME/configs"

# Find and link all .rc files from the current directory
if ! [ -d "${TARGET_DIR}" ];
then
    echo "ERROR: The ${TARGET_DIR} is not present, this folder is required to link y our .rc files."
    echo "Aborting..."
    exit 1;
fi

the_files=( $(find ${TARGET_DIR} -name ".*" -print) )
for the_file in "${the_files[@]}";
do
    # Check if any .rc files exist
    if [ -f "${the_file}" ]; then
        echo "Linked: $the_file -> $HOME/${just_the_file}";
        #Create a symbolic link (-s) and overwrite existing (-f)
        just_the_file=$(basename ${the_file})
        ln -sf "${the_file}" "${HOME}/${just_the_file}";
    fi
done
