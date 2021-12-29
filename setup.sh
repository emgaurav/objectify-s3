#!/bin/bash
echo "$(tput clear)$(tput bel)$(tput bold)"
printf "       _     _           _   _  __                 _____ 
  ___ | |__ (_) ___  ___| |_(_)/ _|_   _       ___|___ / 
 / _ \| '_ \| |/ _ \/ __| __| | |_| | | |_____/ __| |_ \ 
| (_) | |_) | |  __/ (__| |_| |  _| |_| |_____\__ \___) |
 \___/|_.__// |\___|\___|\__|_|_|  \__, |     |___/____/ 
          |__/                     |___/                 
"
tput sgr 0;
set -e
if [ ! -d ~/.objectify-s3 ]; then
	mkdir ~/.objectify-s3
fi
touch ~/.objectify-s3/vulnbuckets.txt
touch ~/.objectify-s3/allbuckets.txt
echo -e "\n\n"
echo "$(tput bold)$(tput setaf 2)<<<<   Beginning Installation   >>>>$(tput sgr 0)"

echo "-----------------------------------"
#setting aliases
chmod +x objectify-s3.sh
#ln -s objectify-s3.sh objectify-s3 2>/dev/null
echo 'alias objectify-s3="bash ~/objectify-s3/objectify-s3.sh"' >> ~/.bashrc
echo 'alias objectify-s3="bash ~/objectify-s3/objectify-s3.sh"' >> ~/.zshrc
echo 'export PATH="$PATH:~/objectify-s3/"' >> ~/.bashrc
echo 'export PATH="$PATH:~/objectify-s3/"' >> ~/.bash_profile
echo 'export PATH="$PATH:~/objectify-s3/"' >> ~/.zshrc
source ~/.bash_profile 2>/duv/null
source ~/.bashrc 2>/dev/null
source ~/.zshrc 2>/dev/null

echo "$(tput bold)Finding ruby" 
if which ruby; then
	echo "$(tput bold)$(tput setaf 2)Found$(tput sgr 0)"
	echo "-----------------------------------"
	echo "Installing required gems"
	bundle install
	echo "$(tput bold)$(tput setaf 2)Done$(tput sgr 0)"
else
	echo "$(tput setaf 1)$(tput bold)it seems ruby is not installed$(tput sgr 0)"
	exit 0;
fi
echo "-----------------------------------"
echo "$(tput bold)Finding awscli" 
if which aws; then
	echo "$(tput bold)$(tput setaf 2)Found$(tput sgr 0)"
	echo "-----------------------------------"
else
	echo "$(tput setaf 1) $(tput bold)it seems awscli is not installed.$(tput sgr 0)"
	echo "$(tput setaf 2) $(tput bold)Trying to install now. $(tput sgr 0)"
	if which brew; then
		brew install awscli
		brew link awscli
		echo "Now you need to set up your credentials for awscli."
		echo "-----------------------------------"
	else
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
		unzip awscliv2.zip
		sudo ./aws/install
		aws --version
		echo "$(tput setaf 2) $(tput bold) $(tput bel)awscli should be installed now. you must set up your aws access using $(tput sgr 0) aws configure"
		echo "-----------------------------------"
	fi
fi
echo "$(tput setaf 2)$(tput bold)$(tput bel)<<<<   Installation Complete   >>>>$(tput sgr 0)"


