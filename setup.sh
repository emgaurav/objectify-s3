#!/bin/bash
echo "$(tput clear)$(tput smso)$(tput bel)$(tput bold)$(tput rev)"
printf "       _     _           _   _  __                 _____ 
  ___ | |__ (_) ___  ___| |_(_)/ _|_   _       ___|___ / 
 / _ \| '_ \| |/ _ \/ __| __| | |_| | | |_____/ __| |_ \ 
| (_) | |_) | |  __/ (__| |_| |  _| |_| |_____\__ \___) |
 \___/|_.__// |\___|\___|\__|_|_|  \__, |     |___/____/ 
          |__/                     |___/                 
"
echo "$(tput sgr 0)"


echo $'\n'"$(tput smso) $(tput setaf 2) Listing available buckets $(tput sgr 0)"$'\n'
rm ~/.objectify-s3/allbuckets.txt 2>/dev/null; touch ~/.objectify-s3/allbuckets.txt 2>/dev/null
aws s3 ls| awk '{print $3}'>>~/.objectify-s3/allbuckets.txt
cat ~/.objectify-s3/allbuckets.txt

echo $'\n'"$(tput smso) $(tput setaf 2)Finding misconfigured buckets. It will take some time. Keep patience...$(tput sgr 0)"$'\n'
rm ~/.objectify-s3/vulnbuckets.txt 2>/dev/null; touch ~/.objectify-s3/vulnbuckets.txt 2>/dev/null;

for bucket in `cat ~/.objectify-s3/allbuckets.txt` 
do
	#if aws s3api get-public-access-block --bucket $bucket 2>&1| grep -q -i -e 'false' -e 'NoSuchPublicAccessBlockConfiguration'  then 
	#this function checks vulnerable buckets from all buckets
	function vulnbuck() {
		#aws s3api get-public-access-block --bucket $bucket >tmp.txt 2>&1 --ignore
		if aws s3api get-public-access-block --bucket $bucket 2>&1|grep -q -i -e 'false' -e 'NoSuchPublicAccessBlockConfiguration'; then
			echo $bucket>> ~/.objectify-s3/vulnbuckets.txt
			echo "$(tput bold) $(tput setaf 1)Found:$(tput sgr 0) $bucket"
		fi
	}
	vulnbuck &
done && wait

echo $'\n'"$(tput bold) $(tput blink) $(tput smso) $(tput setaf 3)Listing public objects from all buckets now $(tput sgr 0)"$'\n'
for bucket in `cat ~/.objectify-s3/vulnbuckets.txt`
do
	#this function checks for vulnerable objects from file vulnbuckets.txt
	function vulnobj() {
	region=`aws s3api get-bucket-location --bucket $bucket| grep -i 'constraint'| cut -d'"' -f4`
	echo "$(tput bold) $(tput setab 7) $(tput setaf 1)Bucket - > $bucket $(tput sgr 0)";
	bundle exec ruby vulnobj.rb $bucket $region
	}
	vulnobj
done


echo $'\n'"$(tput smso) $(tput setaf 2) <<<<<<<<<<<<<<  COMPLETED  >>>>>>>>>>>>>> $(tput sgr 0)"$'\n'
