#!/bin/bash
#
# This script adds the specified user to the Gitolite repository.

set -e -x

TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

git clone $REPOSITORY_URL .
ssh-keygen -b 4096 -t rsa -f keydir/$REMOTE_USER -P ""

echo "@students = `ls keydir`"
git add keydir/$REMOTE_USER.pub conf/gitolite.conf
git commit -m "AUTO: Adding $REMOTE_USER to repository."
git push origin master

cd /
rm -rf $TEMP_DIR