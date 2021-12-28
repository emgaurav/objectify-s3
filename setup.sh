#!/bin/bash
echo "$(tput clear)$(tput bel)$(tput bold)"
printf "       _     _           _   _  __                 _____ 
  ___ | |__ (_) ___  ___| |_(_)/ _|_   _       ___|___ / 
 / _ \| '_ \| |/ _ \/ __| __| | |_| | | |_____/ __| |_ \ 
| (_) | |_) | |  __/ (__| |_| |  _| |_| |_____\__ \___) |
 \___/|_.__// |\___|\___|\__|_|_|  \__, |     |___/____/ 
          |__/                     |___/                 
"
echo "$(tput sgr 0)"
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
if which aws; then
	echo "$(tput bold)Found$(tput sgr 0)"
	echo "--------------------------------"
else
	echo "$(tput setaf 1) $(tput bold)it seems awscli is not installed.$(tput sgr 0)"
	echo "$(tput setaf 2) $(tput bold)Trying to install now. $(tput sgr 0)"
	if which brew; then
		brew install awscli
		brew link awscli
		echo "Now you need to set up your credentials for awscli."
	else
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
		unzip awscliv2.zip
		sudo ./aws/install
		aws --version
		echo "$(tput setaf 2) $(tput bold) $(tput bel)awscli should be installed now. you must set up your aws access using $(tput sgr 0) aws --configure"
	fi
fi
chmod +x objectify-s3.sh
ln -s objectify-s3.sh objectify-s3 2>/dev/null
chmod +x objectify-s3
echo 'export PATH="$PATH:~/objectify-s3/"' > ~/.bashrc
echo 'export PATH="$PATH:~/objectify-s3/"' > ~/.bash_profile
echo 'export PATH="$PATH:~/objectify-s3/"' > ~/.zshrc
source ~/.bashrc
source ~/.zshrc
echo "$(tput setaf 2) $(tput bold) (tput bel )Installation Complete(tput sgr 0)"
