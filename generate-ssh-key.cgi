#!/bin/bash
#
# This script adds the specified user to the Gitolite repository.

echo "Content-type: text/plain"
echo

set -e -x

TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

git clone git@localhost:gitolite-admin $TEMP_DIR 1>&2
ssh-keygen -b 4096 -t rsa -f keydir/$REMOTE_USER -P "" 1>&2

git add keydir/$REMOTE_USER.pub conf/gitolite.conf
git commit --author "Cylon Jeremy <open-source@fatlotus.com>" \
  -m "AUTO: Adding $REMOTE_USER to repository." 1>&2
git push origin master 1>&2

cat keydir/$REMOTE_USER

cd /
rm -rf $TEMP_DIR