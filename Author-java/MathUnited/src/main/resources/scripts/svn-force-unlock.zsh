#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

# Avoid locale errors
LC_CTYPE=

# Check if gawk exist
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
    echo "=== SVNADMIN RMLOCKS on /opt/data/svn/mathplus"
    # Force remove locks on repo
    ## TODO: make paths configurable
    svnadmin rmlocks /opt/data/svn/mathplus $(svnadmin lslocks /opt/data/svn/mathplus | grep '^Path: /' | cut -c 7-)

    echo "*** DONE. SVNADMIN RMLOCKS on /opt/data/svn/mathplus"

} |& println
