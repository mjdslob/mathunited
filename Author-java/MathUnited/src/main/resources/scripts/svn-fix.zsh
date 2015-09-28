#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

# Avoid locale errors
LC_CTYPE=

echo "=== SVN FIX on '${ARG1}'" | tee  "${ARG2}"
echo "--- Logging send to '${ARG2}'" | tee -a "${ARG2}"

if [[ ! -e "${ARG1}" ]]; then
    echo "*** Error: Path '${ARG1}' does not exist"
    exit 1
fi

cd ${ARG1}

# Cleanup svn tree
echo "--- Running svn cleanup" |& tee -a "${ARG2}"
svn cleanup

# Find content directories by looking for index.xml
indexes=$(/bin/ls -1 **/index.xml)
dirs=$(for index in ${(f)indexes}; do echo ${index:h}; done)
for d in ${(f)dirs}; do ( # in subshell
    cd $d
    echo "--- Trying to fix ${ARG1}/${d}" |& tee -a "${ARG2}"
    comp=$d:h
    subcomp=$d:t
    # Add images
    svn add --parents --force images/highres/*.* |& tee -a "${ARG2}"
    # Add xml files
    svn add --parents --force */*.xml |& tee -a "${ARG2}"
    svn commit . -m "Added unversioned files in $d" |& tee -a "${ARG2}"
)
done

# Run an update and accept conflicts
echo "--- Pull in changes from repo" |& tee -a "${ARG2}"
svn update --accept mine-conflict "$ARG1" |& tee -a "${ARG2}"

# Put back to the server
echo "--- Put back resolved conflictes to repo" |& tee -a "${ARG2}"
svn commit "$ARG1" -m "Overruled conflicts" |& tee -a "${ARG2}"
