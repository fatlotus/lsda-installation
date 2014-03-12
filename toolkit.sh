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
  echo
  echo "Something has gone very wrong!"
  echo "Please email the contents of install.log to jarcher@uchicago.edu."
  echo
}

trap exit_handler ERR

echo "--- NEW INSTALL --" >> install.log
date >> install.log

echo
echo
echo "Hello there! Let's walk through a basic installation of three useful"
echo "software packages: Git, Python, and Virtualenv; and then set up your"
echo "computer to submit jobs to the Amazon Elastic Compute Cloud."
echo

sleep 2

if ! which git > /dev/null; then
  echo
  echo "I'm unable to find Git, a source code management package. Please do"
  echo "that before continuing. Unfortunately the actual steps required to do"
  echo "this vary by platform, but the following should get you started:"
  echo
  echo "  http://git-scm.com/book/en/Getting-Started-Installing-Git"
  echo
  
  exit 1
else
  echo "It appears that you already have Git!"
fi

sleep 2

if ( ! which python > /dev/null ); then
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
  
  exit 1
else
  echo "It appears you already have Python."
fi

sleep 2

echo
echo "Next, let's install Virtualenv. This is a software package that makes"
echo "Installation of future software packages easier."

rm -rf virtualenv
git clone --depth 1 https://github.com/pypa/virtualenv 2>>install.log \
  >> install.log

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

echo -n "Please enter your CNetID: "
CNETID="$(head -n 1 /dev/tty)"

if [ ! -f .lsda_ssh_key.pem ]; then
  curl --insecure -k -s -u $CNETID https://lsda.cs.uchicago.edu/generate-ssh-key.cgi > .lsda_ssh_key.pem
  chmod 0400 .lsda_ssh_key.pem
  ssh-add .lsda_ssh_key.pem
fi

if [ ! -d .git ]; then
  echo
  echo "Next, let's download the starter projects for this assignment. If prompted to"
  echo "\"Are you sure you want to...\", just type yes."
  echo

  # Fixme: this is very insecure.
  ssh-keygen -R lsda.cs.uchicago.edu || true
  ssh-keygen -R 54.197.243.75 || true
  echo "lsda.cs.uchicago.edu ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo6i5Y70XoHziSDs0cfJyR+h+HJmjJ8ojtKymKnm66XOt8kniAkmdyxlTuFcZbhGNZjRbeOICf+aMhV+fkDUyCi/f/AF4adRHaTIgqXs2UGdq88T9arFYTXMT3RYyVt7ccA1LPsH0pSvwDeRJAJMacpdwFB/l7Kz6UAENYcIlCmWPoo4Md0W71da9PsT+QDAN9Qeww/ndOwQo7c4AsPJS2ySEgtz/7ratxeKc7es7MXqxR3X3a/SVRKnfyYMrMcT5LyujzoUpOr9blmDoX1To/0KOGHZ3F6LD53ScT4lHbUWT238xLV9KeO8PPJ1zlVRZQoo7R5u6fF3L0lZloVqVb" >> ~/.ssh/known_hosts
  
  git clone git@lsda.cs.uchicago.edu:assignment-one .clone-dest.tmp \
    2>>install.log >> install.log
  mv .clone-dest.tmp/.git .git
  git reset --hard HEAD 2>>install.log >>install.log
fi

echo
echo "Hang tight -- this may take a few minutes."
echo

echo -ne "Bootstrapping virtualenv...\r"
python virtualenv/virtualenv.py bootstrap >> install.log
bootstrap/bin/pip install virtualenv >> install.log
bootstrap/bin/virtualenv . >> install.log
rm -rf bootstrap virtualenv
echo -ne "Adding new LSDA SSH key...\r"

echo "ssh-add .lsda_ssh_key.pem" >> bin/activate

. bin/activate

echo -ne "Installing FFTW3...\r"
curl --no-progress "http://www.fftw.org/fftw-3.3.3.tar.gz" >> fftw-3.3.3.tar.gz
tar xf fftw-3.3.3.tar.gz
cd fftw-3.3.3
./configure --prefix="$(pwd)/.."
make
make install
cd ..

echo -ne "Installing ZMQ...\r"
pip install --global-option="fetch_libzmq" pyzmq >> install.log

echo -ne "Installing Cython and numpy...\r"
pip install Cython numpy >> install.log

echo -ne "Installing remaining dependencies...\r"
pip install -r requirements.txt >> install.log

echo -ne "Copying to new git branch...\r"
git checkout -B "submissions/$CNETID/submit" 2>> install.log

echo -ne "Configuring git...\r"
git config --local user.name $CNETID
git config --local user.email $CNETID@uchicago.edu

echo -ne "                                           \r"
echo "Installation complete."
echo
echo "Excellent. It appears everything is in order. If you are having"
echo "problems, please find Jeremy and bother him until he makes everything"
echo "better."
echo
