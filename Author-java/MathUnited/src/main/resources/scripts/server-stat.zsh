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
    /bin/cat
}
else
function println() {
    gawk '{ print strftime("%Y-%m-%d|%H:%M:%S|"), $0; fflush(); }'
}
fi

# Capture all output
{
    echo "=== SERVER STAT"
    # We use zsh's builtin knowledge of the parent process it (PPID)
    echo "--- Server runs as $PPID"
    # Use ps for information
    ps -p $PPID -o pid,pcpu,pmem,rss,vsz,time,command

    echo "*** DONE."

} |& println
