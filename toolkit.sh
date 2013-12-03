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

if ! which git > /dev/null; then
  echo
  echo "I'm unable to find Git, a source code management package. Let's"
  echo "install it now:"
  echo
  
  sudo aptitude install git-core
  
  echo
  echo "It appears that went well. Let's continue."
  echo
fi

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

echo
echo "Now we will set up "`pwd`" as the working directory for this class."
echo "When working on code, be sure to return to this directory before"
echo "making changes."
echo

if ( ! -f .lsda-ssh-key ); then
  curl https://lsda.cs.uchicago.edu/generate-ssh-key.sh > .lsda_ssh_key
fi

git clone git@lsda.uchicago.edu:assignment-one
virtualenv .
source bin/activate
pip install -r requirements.txt

echo
echo "Excellent. It appears everything is in order."
echo
