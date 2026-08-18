#!/usr/bin/sh

if ! [ -f ~/.bashrc_keys ];
then
    echo "ERROR: Your ~/.bashrc_keys file does not exit.  This script assumes your settings are obfuscated there.";
    echo "Aborting execution...";
    exit 1;
fi

echo "Setting user.email to ${GIT_AUTHOR_EMAIL}";
git config --global user.email "${GIT_AUTHOR_EMAIL}"

echo "Setting user.email to ${GIT_AUTHOR_NAME}";
git config --global user.name "${GIT_AUTHOR_NAME}"
