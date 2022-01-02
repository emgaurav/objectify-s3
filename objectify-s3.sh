#!/bin/bash
#error handler
trap "exit" SIGINT SIGSTOP
trap "echo $'\n''$(tput bold)..bye!'; kill 0" EXIT

#refresh files
rm ~/.objectify-s3/allbuckets.txt 2>/dev/null; touch ~/.objectify-s3/allbuckets.txt 2>/dev/null
rm ~/.objectify-s3/vulnbuckets.txt 2>/dev/null; touch ~/.objectify-s3/vulnbuckets.txt 2>/dev/null;

#check arguments
if [ ! -z "$1" ]; then
	if [[ $1 == r ]]; then
		if [ ! -z "$2" ]; then
			echo "second"
			file=$2; cat $file;
		else 
			echo "Too few arguments";
			exit 0;
		fi
	elif [[ $1 != r ]]; then
		echo "Invalid argument"; 
		exit 0;
	fi
fi

#function to print banner
function printbanner() {
tput clear;
tput bel;
tput bold;
printf "       _     _           _   _  __                 _____ 
  ___ | |__ (_) ___  ___| |_(_)/ _|_   _       ___|___ / 
 / _ \| '_ \| |/ _ \/ __| __| | |_| | | |_____/ __| |_ \ 
| (_) | |_) | |  __/ (__| |_| |  _| |_| |_____\__ \___) |
 \___/|_.__// |\___|\___|\__|_|_|  \__, |     |___/____/ 
          |__/                     |___/                 
"
tput sgr 0;
}

#checks and installs updates
function checkupdates() {
echo $'\n'"$(tput bold)Fetching updates.. $(tput sgr 0)"
cd ~/objectify-s3; git reset --hard >/dev/null 2>&1; 
git pull 1> ~/.objectify-s3/tmp.txt
if cat ~/.objectify-s3/tmp.txt|grep -q -i 'changed'; then
	echo "$(tput bold)Updated Successfully"
	echo "Relaunching.."
	sleep 1;
	bash ~/objectify-s3/objectify-s3.sh;
else
	echo "$(tput setaf 2)$(tput bold)Using latest version$(tput sgr 0)"$'\n';
fi
}

function checkaws() {
echo "checking awscli configuration"
if ! aws configure list-profiles|grep -q -i "default"; then
	echo "$(tput bold)$(tput setaf 1)awscli is not configured. You must configure using 'aws configure' command.$(tput sgr 0)"$'\n'
	exit 0
else echo "$(tput setaf 2)$(tput bold)OK$(tput sgr 0)"; fi

echo "----------------------------------------"
}
	



function listbuckets () {
echo $'\n'"$(tput smso)$(tput setaf 2)Listing available buckets $(tput sgr 0)"$'\n'
if [[ ! $file ]]; then
	aws s3 ls| awk '{print $3}'>>~/.objectify-s3/allbuckets.txt
	file=~/.objectify-s3/allbuckets.txt
fi
tput setaf 2; cat $file
echo $'\n';

}

#finds vulnerable buckets
function findvulnbuckets() {
	#aws s3api get-public-access-block --bucket $bucket >tmp.txt 2>&1 --ignore
	if aws s3api get-public-access-block --bucket $bucket 2>&1|grep -q -i -e 'false' -e 'NoSuchPublicAccessBlockConfiguration'; then
		echo $bucket>> ~/.objectify-s3/vulnbuckets.txt
		echo "$(tput bold)$(tput setaf 1)Found:$(tput sgr 0) $bucket"
	fi
}
function printmisconfbuckets () {
echo $'\n'"$(tput smso)$(tput setaf 172)Finding misconfigured buckets. It takes a few seconds..$(tput sgr 0)"$'\n'
for bucket in `cat $file` 
do
	#this function checks vulnerable buckets from all buckets
	findvulnbuckets &
done && wait
}

#this function checks for vulnerable objects from file vulnbuckets.txt
function findvulnobj() {
region=`aws s3api get-bucket-location --bucket $bucket| grep -i 'constraint'| cut -d'"' -f4`
bundle exec ruby vulnobj.rb $bucket $region
}

	printbanner; checkupdates; checkaws; listbuckets; printmisconfbuckets; 
	echo $'\n'"$(tput bold)$(tput setab 7)$(tput setaf 1)Listing public objects from all buckets now $(tput sgr 0)"$'\n'
	for bucket in `cat ~/.objectify-s3/vulnbuckets.txt`
	do
		echo "$(tput bold)$(tput setaf 1)Bucket - > $bucket $(tput sgr 0)";
		findvulnobj;
	done

echo $'\n'"$(tput smso) $(tput setaf 2) <<<<<<<<<<<<<<  COMPLETED  >>>>>>>>>>>>>> $(tput sgr 0)"$'\n'
