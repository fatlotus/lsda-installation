#!/bin/bash
#
# Installs the necessary tools used in CMSC 25025 "Machine Learning and
# Large-Scale Data Analysis," a course taught by John Lafferty at the
# University of Chicago.
#
# If you're reading this you probably don't need this script --- all it does
# is install Git, Python, and Virtualenv on a reasonably sane Debian-like
# environment. In any case pull requests are welcome :)

set -e

echo
echo
echo "Hello there! Let's walk through a basic installation of three useful"
echo "software packages: Git, Python, and Virtualenv; and then set up your"
echo "computer to submit jobs to the Amazon Elastic Compute Cloud."
echo

sleep 2

if ! which git > /dev/null; then
  echo
  echo "I'm unable to find Git, a source code management package. Let's"
  echo "install it now:"
  echo
  
  sudo aptitude install git-core
  
  echo
  echo "It appears that went well. Let's continue."
  echo
else
  echo "It appears that you already have Git!"
fi

sleep 2

if ( ! which python > /dev/null ); then
  echo "I'm unable to find Python- let's install that now:"
  echo
  
  sudo aptitude install python python-distribute python-virtualenv
  
  echo
  echo "Let's continue."
  echo
else
  echo "It appears you already have Python."
fi

sleep 2

if ( ! which virtualenv > /dev/null ); then
  echo
  echo "We also will need to install Virtualenv, a Python installation"
  echo "manager."
  echo
  
  sudo pip install -r virtualenv
  
  echo
  echo "We were successsful."
  echo
else
  echo "It appears you already have Virtualenv."
fi

sleep 2

echo
echo "Now we will set up"
echo
echo "  `pwd`"
echo
echo "as the working directory for this class. When working on code, be sure to return"
echo "to this directory before making changes. Next we're going to set up your computer"
echo "to use your CNetID account for submitting assignments."
echo

sleep 2

echo -n "Please enter your CNetID: "
CNETID="$(head -n 1 /dev/tty)"

if [ ! -f .lsda_ssh_key.pem ]; then
  curl --insecure -s -u $CNETID https://lsda.cs.uchicago.edu/generate-ssh-key.cgi > .lsda_ssh_key.pem
  chmod 0400 .lsda_ssh_key.pem
  ssh-add .lsda_ssh_key.pem
fi

if [ ! -d .git ]; then
  echo
  echo "Next, let's download the starter projects for this assignment. If prompted to"
  echo "\"Are you sure you want to...\", just type yes."
  echo

  git clone git@lsda.cs.uchicago.edu:assignment-one .clone-dest.tmp >> install.log
  mv .clone-dest.tmp/.git .git
  git reset --hard HEAD
fi

echo
echo "Hang tight -- this may take a few minutes."
echo
virtualenv . >> install.log
cat >> bin/activate <<EOF

\# This last bit was added by the LSDA installer script, just for you!
ssh-add .lsda_ssh_key.pem
EOF

source bin/activate
pip install -r requirements.txt >> install.log
git checkout -b "submissions/$CNETID/submit" >> install.log

echo
echo
echo "Excellent. It appears everything is in order. If you are having"
echo "problems, please find Jeremy and bother him until he makes everything"
echo "better. Best of luck,"
echo
echo "     -J"
echo
echo
