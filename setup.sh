#!/bin/bash
set -e
if [ ! -d ~/.objectify-s3 ]; then
	mkdir ~/.objectify-s3
fi
touch ~/.objectify-s3/vulnbuckets.txt
touch ~/.objectify-s3/allbuckets.txt
echo "$(tput setaf 2)Finding ruby" 
if which ruby; then
	echo "$(tput bold)Found$(tput sgr 0)"
	echo "Installing required gems"
	bundle install
	echo "--------------------------------"
else
	echo "$(tput setaf 1) $(tput bold)it seems ruby is not installed$(tput sgr 0)"
fi
echo "$(tput setaf 2)Finding awscli" 
if which aws; then
	echo "$(tput bold)Found$(tput sgr 0)"
	echo "--------------------------------"
else
	echo "$(tput setaf 1) $(tput bold)it seems awscli is not installed$(tput sgr 0)"
fi
ln -s runner.sh objectify-s3
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.bashrc
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.bash_profile
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.zshrc
source ~/.bashrc
source ~/.zshrc
echo "$(tput setaf 2) $(tput bold) (tput bil )Installation Complete(tput sgr 0)"
