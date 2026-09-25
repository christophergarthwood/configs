# GIT

[TOC]

## GIT GENERAL PROCESS

1. `git add/commit/push/stash`  #whatever local changes you have in your branch
2. `git checkout master/main`
3. `git pull`
4. `git checkout <your branch>`
5. `git merge master/main`      #now you're 100% up to date
6. TEST TEST TEST TEST TEST!!!!!
7. `git push`                   #these changes from master inside your branch up
8. `git checkout master`
9. `git pull`                   #one more time on master to ensure you're up to date.
10.`git merge <your branch>`    #now you have a local copy of master on your system
11.TEST TEST TEST TEST TEST!!!!!
12.`git push`                   #now the central repo's master is up to date and has been tested

## GIT alias

`alias git_report="git log --graph --decorate --pretty=format:'%C(yellow)%h %Cred%cr %Cblue(%an)%C(cyan)%d%Creset %s' --abbrev-commit |head -40"`

`alias git_tags="git log --no-walk --tags --pretty='%h %d %s' --decorate=full"`

`alias show_versions="git log --no-walk --tags --pretty='%h %d %s' --decorate=full"`

## GIT CLEAN EVERYTHING (Dangerous)

`git clean -fd`

## GIT RESET

`git reset --hard`

## GIT NUKE

`git clean -fd; git reset --hard`

## GIT REPO CRASHING

1. `chown -R me:me *`
2. `chmod -R ugo+rx *`
3. `git fsck`   #performs a file integrity check
4. `git prune`  #an internal housekeeping utility that cleans up unreachable or "orphaned" Git objects
5. `git repack` #combine all objects that do not currently reside in a "pack", into a pack. It can also be used to re-organize existing packs into a single, more efficient pack.
6. `git fsck`

## GIT LOG

***Reference:*** [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials/git-log)

`git log --graph --oneline --decorate`

Limit output.

`git log --graph --oneline --decorate -10`

## GIT PERMISSIONS

Set execute bit on a file.

`git add install.sh --chmod=+x`

***Reference for Best Practices:*** [Dune Project Best Practices](https://www.dune-project.org/doc/guides/git_best_practices/)

## GIT SSL ISSUES

http.slCAPath or http.sslCAInfo. Adam Spiers's answer gives some great examples. This is the most secure solution to the question.

To disable TLS/SSL verification for a single git command try passing -c to git with the proper config variable, or use Flow's answer:

`git -c http.sslVerify=false clone https://example.com/path/to/git`

To disable SSL verification for a specific repository if the repository is completely under your control, you can try:

`git config http.sslVerify false`

There are quite a few SSL configuration options in git. From the man page of git config:

**http.sslVerify** - Whether to verify the SSL certificate when fetching or pushing over HTTPS.  Can be overridden by the GIT_SSL_NO_VERIFY environment variable.

**http.sslCAInfo** - File containing the certificates to verify the peer with when fetching or pushing over HTTPS. Can be overridden by the GIT_SSL_CAINFO environment variable.

**http.sslCAPath** - Path containing files with the CA certificates to verify the peer with when fetching or pushing over HTTPS.  Can be overridden by the GIT_SSL_CAPATH environment variable.

A few other useful SSL configuration options:

**http.sslCert** - File containing the SSL certificate when fetching or pushing over HTTPS.  Can be overridden by the GIT_SSL_CERT environment variable.

**http.sslKey** - File containing the SSL private key when fetching or pushing over HTTPS.  Can be overridden by the GIT_SSL_KEY environment variable.

**http.sslCertPasswordProtected** - Enable git's password prompt for the SSL certificate. Otherwise OpenSSL will prompt the user, possibly many times, if the certificate or private key is encrypted.  Can be overridden by the GIT_SSL_CERT_PASSWORD_PROTECTED environment variable.

## SUBVERSION LOG

Show descending values, last 10 only.

`svn log -r HEAD:1 -l 10`

## SUBVERSION on DSRC

`module load costinit`

`module load subversion`
