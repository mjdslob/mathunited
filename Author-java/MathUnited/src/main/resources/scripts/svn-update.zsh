#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

# Avoid locale errors
LC_CTYPE=

# Define println function that writes to output and to the file indicated by ARG2. If gawk is present the lines
# are prependend with a time stamp
if ! type gawk > /dev/null; then
function println() {
    /usr/bin/tee -a "${ARG2}"
}
else
function println() {
    gawk '{ print strftime("%Y-%m-%d|%H:%M:%S|"), $0; fflush(); }' | /usr/bin/tee -a "${ARG2}"
}
fi

# Capture all output
{
    echo "=== SVN UPDATE on '${ARG1}'"
    echo "--- Logging send to '${ARG2}'"

    echo "--- Running 'svn update' on ${ARG1}"

    # Run global update
    svn update --accept mine-conflict "$ARG1"


    # If it failed run update on all directories separate and tell user to run fix
    if [ $? -ne 0 ]; then
        echo "!!! Global update failed, will update directories one-by-one"
        # Find all children, sort from longest path length to shortest, so we hit most specific dires first
        # (as a child directory will have a longer full path length than its parent)
        dirs=$(find . -type d -not -name ".*" | grep -v .svn | awk '{print length, $0;}' | sort -nr | cut -f 2- -d ' ')
        for d in ${(f)dirs}; do
            svn update --accept mine-conflict "$d"
        done
        echo "!!! Because global update failed, please run svn-update with fix=true!"
    fi

    echo "*** DONE. SVN UPDATE on '${ARG1}'"

} |& println
