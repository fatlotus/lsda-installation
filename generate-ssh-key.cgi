#!/bin/bash
#
# This script adds the specified user to the Gitolite repository.

echo "Content-type: text/plain"
echo

set -e -x

TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

NONCE=$(date +%s.%N)

# Pre-verify host checking (this is a hack!)
ssh -o StrictHostKeyChecking=no git@localhost echo 1>&2 || true

# Clone existing repository values
git clone git@localhost:gitolite-admin $TEMP_DIR 1>&2

# Generate a new certificate
mkdir keydir/$NONCE
ssh-keygen -b 4096 -t rsa -f keydir/$NONCE/$REMOTE_USER -P "" 1>&2

# Add the new certificate to gitolite
git add keydir/$NONCE/$REMOTE_USER.pub conf/gitolite.conf

# Generate the automated commit
git commit --author "Cylon Jeremy <open-source@fatlotus.com>" \
  -m "AUTO: Adding $REMOTE_USER to repository." 1>&2

# A huge race condition!
git push origin master 1>&2

cat keydir/$NONCE/$REMOTE_USER

cd /
rm -rf $TEMP_DIR
