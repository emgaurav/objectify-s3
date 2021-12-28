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
	exit 1;
fi
echo "$(tput setaf 2)Finding awscli" 
if which awss; then
	echo "$(tput bold)Found$(tput sgr 0)"
	echo "--------------------------------"
else
	echo "$(tput setaf 1) $(tput bold)it seems awscli is not installed.$(tput sgr 0)"
	echo "$(tput setaf 2) $(tput bold)Installing now. $(tput sgr 0)"
	if which brew; then
		brew install awscli
		brew link awscli
		echo "Now you need to set up your credentials for awscli."
	else
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
		unzip awscliv2.zip
		sudo ./aws/install
		aws --version
	fi
fi
ln -s objectify-s3.sh objectify-s3
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.bashrc
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.bash_profile
echo 'export PATH="$PATH:~/objectify-s3/' > ~/.zshrc
source ~/.bashrc
source ~/.zshrc
echo "$(tput setaf 2) $(tput bold) (tput bil )Installation Complete(tput sgr 0)"
