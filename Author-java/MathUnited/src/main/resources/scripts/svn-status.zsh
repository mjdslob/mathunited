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
    tee -a "${ARG2}"
}
else
function println() {
    gawk '{ print strftime("%Y-%m-%d|%H:%M:%S|"), $0; fflush(); }' | tee -a "${ARG2}"
}
fi

# Capture all output
{
    echo "=== SVN STATUS on '${ARG1}'"

    if [[ ! -e "${ARG1}" ]]; then
        echo "*** Error: Path '${ARG1}' does not exist"
        exit 1
    fi

    svn status "$ARG1"

    echo "*** DONE. SVN FIX on '${ARG1}'"

} |& println
