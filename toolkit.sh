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

exit_handler() {
  set +x
  echo
  echo "Something has gone very wrong!"
  echo "Please email the contents of install.log to jarcher@uchicago.edu."
  echo
}

trap exit_handler ERR

echo "--- NEW INSTALL --" >> install.log
date >> install.log

set +x
echo
echo
echo "Hello there! Let's walk through a basic installation of three useful"
echo "software packages: Git, Python, and Virtualenv; and then set up your"
echo "computer to submit jobs to the Amazon Elastic Compute Cloud."
echo

sleep 2

if ! which git > /dev/null; then
  set +x
  echo
  echo "I'm unable to find Git, a source code management package. Please do"
  echo "that before continuing. Unfortunately the actual steps required to do"
  echo "this vary by platform, but the following should get you started:"
  echo
  echo "  http://git-scm.com/book/en/Getting-Started-Installing-Git"
  echo
  
  exit 1
else
  set +x
  echo "It appears that you already have Git!"
fi

sleep 2
set -x

if ( ! which python > /dev/null ); then
  set +x
  echo "I'm unable to find Python. There are several reasons why this might"
  echo "occur, even if you do have it installed. Please verify that you can run"
  echo "\"python\" (without quotes) and then re-run this script."
  echo
  echo "If you're not sure where to begin, try the following platform-specific"
  echo "tutorial. If possible, try to install Python 2.7, since that's likely"
  echo "what your classmates are using -- but either will work in this course."
  echo
  echo "  https://wiki.python.org/moin/BeginnersGuide/Download"
  echo
  set -x
  
  exit 1
else
  set +x
  echo "It appears you already have Python."
fi

sleep 2

echo
echo "Next, let's install Virtualenv. This is a software package that makes"
echo "Installation of future software packages easier."
echo

set -x

if which conda; then
  conda create -p $(pwd) python=2.7 numpy=1.6 scipy=0.14 >> install.log
else
  pip install --user virtualenv >> install.log
fi

set +x
sleep 2

echo
echo "Now we will set up"
echo
echo "  `pwd`"
echo
echo "as the working directory for this class. When working on code, be sure"
echo "to return to this directory before making changes. Next we're going"
echo "to set up your computer to use your CNetID for submitting assignments."
echo

sleep 2

if [ "x$TEST_CNETID" == "x" ]; then
  echo -n "Please enter your CNetID: "
  CNETID="$(head -n 1 /dev/tty)"
else
  CNETID="$TEST_CNETID"
  touch .lsda_ssh_key.pem
fi

set -x

mkdir -p ~/.ssh

if [ -f .lsda_ssh_key.pem ]; then
  if ! grep "BEGIN RSA PRIVATE KEY" .lsda_ssh_key.pem ; then
    rm -rf .lsda_ssh_key.pem
  fi
fi

if [ ! -f .lsda_ssh_key.pem ]; then
  curl --insecure -k -s -u $CNETID https://lsda.cs.uchicago.edu/cgi-bin/generate-ssh-key.cgi > .lsda_ssh_key.pem
  chmod 0400 .lsda_ssh_key.pem
  
  if ! grep "BEGIN RSA PRIVATE KEY" .lsda_ssh_key.pem ; then
    exit 1
  fi
fi

echo "#!/bin/bash" > .ssh.sh
echo "ssh -i .lsda_ssh_key.pem \$@" >> .ssh.sh
chmod +x .ssh.sh

export GIT_SSH="$(pwd)/.ssh.sh"

if [ ! -f main.ipynb ]; then
  rm -rf .git
fi

if [ ! -d .git ]; then
  set +x
  echo
  echo "Next, let's download the starter projects for this assignment. If prompted to"
  echo "\"Are you sure you want to...\", just type yes."
  echo
  set -x

  # Fixme: this is very insecure.
  ssh-keygen -R lsda.cs.uchicago.edu || true
  ssh-keygen -R 54.197.243.75 || true
  echo "lsda.cs.uchicago.edu ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo6i5Y70XoHziSDs0cfJyR+h+HJmjJ8ojtKymKnm66XOt8kniAkmdyxlTuFcZbhGNZjRbeOICf+aMhV+fkDUyCi/f/AF4adRHaTIgqXs2UGdq88T9arFYTXMT3RYyVt7ccA1LPsH0pSvwDeRJAJMacpdwFB/l7Kz6UAENYcIlCmWPoo4Md0W71da9PsT+QDAN9Qeww/ndOwQo7c4AsPJS2ySEgtz/7ratxeKc7es7MXqxR3X3a/SVRKnfyYMrMcT5LyujzoUpOr9blmDoX1To/0KOGHZ3F6LD53ScT4lHbUWT238xLV9KeO8PPJ1zlVRZQoo7R5u6fF3L0lZloVqVb" >> ~/.ssh/known_hosts
  
  git clone git@lsda.cs.uchicago.edu:assignment-one .clone-dest.tmp \
    2>>install.log >> install.log
  mv .clone-dest.tmp/.git .git
  git reset --hard HEAD 2>>install.log >>install.log
fi

set +x
echo
echo "Hang tight -- this may take a few minutes."
echo

echo
echo "Setting up a virtual environment..."
echo
set -x

if ! which conda; then
  rm -rf bin/activate # silence warnings
  virtualenv --system-site-packages .
fi

set +x
echo
echo "Adding new LSDA SSH key..."
echo
set -x

echo "eval \$(ssh-agent)" >> bin/activate
echo "ssh-add .lsda_ssh_key.pem 2>&1 | grep -v \"Identity added\" || true" >> bin/activate
echo "export GIT_SSH=\"\$(pwd)/.ssh.sh\"" >> bin/activate

. bin/activate

set +x
echo
echo "Installing ZMQ..."
echo
set -x

pip install --global-option="fetch_libzmq" pyzmq >> install.log

set +x
echo
echo "Installing Cython and numpy..."
echo
set -x

pip install Cython numpy scipy >> install.log

set +x
echo
echo "Installing remaining dependencies..."
echo
set -x

pip install -r requirements.txt >> install.log

set +x
echo
echo "Copying to new git branch..."
echo
set -x

git checkout -B "submissions/$CNETID/submit" 2>> install.log

set +x
echo
echo "Configuring git..."
echo
set -x
git config --local user.name $CNETID
git config --local user.email $CNETID@uchicago.edu

set +x
echo
echo "Installation complete."
echo
echo "Excellent. It appears everything is in order. If you are having"
echo "problems, please find Jeremy and bother him until he makes everything"
echo "better."
echo
