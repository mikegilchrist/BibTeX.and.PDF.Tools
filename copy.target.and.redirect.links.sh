#!/bin/bash
#
# Script to help organize repositories.
# Finds local links pointing to REFDIRCURRENT (e.g. /home/user/References)
# Copies target to REFDIRNEW
# Removes symbolic link pointing to REFDIRCURRENT
# Replaces it with one pointing to file in REFDIRNEW
#
# Expects 2 arguments

if [ "$#" -ne 2 ];
then
    echo "Error in $0:  Need 2 arguments: <FILELINK> and <REFDIRNEW>";
    exit 1;
fi



LINK="$1";
REFDIRNEW="${2%/}"; #remove any trailing slash
echo $REFDIRNEW;

#Test for broken link
# test if symlink is broken (by seeing if it links to an existing file)
if [ -h "$LINK" -a ! -e "$LINK"  ] ; then
    # symlink is broken
    echo "Exiting\n";
    exit 1;
fi

LINKBASE="$(basename "$LINK")";
TARGET="$(readlink "$LINK")";
TARGETBASE="$(basename "$TARGET")";
NEWTARGET="$REFDIRNEW/$TARGETBASE";




if [ "$TARGET" == "$NEWTARGET" ];
then
    printf "$LINK already points to $NEWTARGET so there's nothing to do\nExiting\n"; 
    exit 0;
fi

cp -f "$TARGET" "$REFDIRNEW/$TARGETBASE" &&
   printf "$TARGET copied to $REFDIRNEW\n"; # ||
#   { printf "Exiting"; exit 1; }
# and alternative way to check errors
# [ $? -neq 0 ] && printf "Copy $LINK to $REFDIRNEW failed\nExiting"

mv -f "$LINK" /tmp/. ;
if [ $? -eq 0 ];
then
    echo "Link moved to /tmp";
else
    echo "Link not moved. Exiting";
    exit 1;
fi

# For generality, I think I should use $LINK not $LINKBASE
ln -s "$NEWTARGET" "$LINK";
if [ $? -eq 0 ];
then
    echo "Success!";
    exit 0
else
    echo "Couldn't make link to new target. Restoring link and exiting";
    mv "/tmp/$LINKBASE" "$LINK";
    exit 1;
fi

