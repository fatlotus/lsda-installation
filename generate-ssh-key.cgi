#!/bin/bash
#
# This script adds the specified user to the Gitolite repository.

echo "Content-type: text/plain"
echo

set -e -x

TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

git clone git@localhost:gitolite-admin .
ssh-keygen -b 4096 -t rsa -f keydir/$REMOTE_USER -P ""

echo "@students = `ls keydir`"
git add keydir/$REMOTE_USER.pub conf/gitolite.conf
git commit -m "AUTO: Adding $REMOTE_USER to repository."
git push origin master

cd /
rm -rf $TEMP_DIR