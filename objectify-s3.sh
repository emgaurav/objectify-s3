#!/bin/bash
#error handler
trap "exit" SIGINT SIGSTOP
trap "echo $'\n'; kill 0" EXIT
#'$(tput bold)..bye!'

#help 
function help() {

	echo $'\n'
	echo "$(tput bold)Usage : $(tput sgr 0)"$'\n'
	echo "• To Run a fully automated scan:$(tput sgr 0)"$'\n'
	echo "    $(tput bold)\$ objectify-s3$(tput sgr 0)"$'\n'
	echo "• To scan a single bucket:$(tput sgr 0)"$'\n'
	echo "    $(tput bold)\$ objectify-s3 -b $(tput setaf 3)<bucket-name>$(tput sgr 0)"$'\n'
	echo "• To scan a list of buckets:$(tput sgr 0)"$'\n'
	echo "    $(tput bold)\$ objectify-s3 -r $(tput setaf 3)</full/path/to/target-file.txt>$(tput sgr 0)"
} 

#refresh files
rm ~/.objectify-s3/allbuckets.txt 2>/dev/null; touch ~/.objectify-s3/allbuckets.txt 2>/dev/null
rm ~/.objectify-s3/vulnbuckets.txt 2>/dev/null; touch ~/.objectify-s3/vulnbuckets.txt 2>/dev/null
rm ~/objectify-s3/out.html

#check arguments
if [ ! -z "$1" ]; then
	if [[ $1 == "-r" ]]; then
		if [ ! -z "$2" ]; then
			file=$2;
		else 
			echo $'\n'"$(tput setaf 1)Target file not specified$(tput sgr 0)";
			help;
			exit;
		fi
	elif [[ $1 == "-b" ]]; then
		if [ ! -z "$2" ]; then
			echo $2>~/.objectify-s3/allbuckets.txt;
			file=~/.objectify-s3/allbuckets.txt;
		else 
			echo $'\n'"$(tput setaf 1)Target bucket not specified$(tput sgr 0)";
			help;
			exit;
		fi
	elif [[ $1 != "-r" || $1 != "-b" ]]; then
		echo $'\n'"$(tput setaf 1)Invalid argument$(tput sgr 0)"; 
		help;
		exit;
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
echo $'\n'"$(tput bold)Checking for updates.. $(tput sgr 0)"
cd ~/objectify-s3; git reset --hard >/dev/null 2>&1; 
git pull > ~/.objectify-s3/tmp.txt 2>/dev/null
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
#echo "checking awscli configuration"
if ! aws configure list-profiles|grep -q -i "default"; then
	echo "$(tput bold)$(tput setaf 1)awscli is not configured. You must configure using 'aws configure' command.$(tput sgr 0)"$'\n'
	exit 0
fi

echo "----------------------------------------"
}
#Lists all available buckets
function listbuckets () {
echo $'\n'"$(tput smso)$(tput setaf 2)Listing available buckets $(tput sgr 0)"$'\n'
echo '<div class="panel-group" id="accordion"><div class="panel panel-default"><div class="panel-heading"><a data-toggle="collapse" data-parent="#accordion" href="#available"><h4 class="panel-title" style="color:Green;">Buckets Scanned</h4></a></div><div id="available" class="panel-collapse collapse"><div class="panel-body" style="color:Green;">'>>out.html

if [[ ! $file ]]; then
	aws s3 ls| awk '{print $3}'>>~/.objectify-s3/allbuckets.txt
	file=~/.objectify-s3/allbuckets.txt
fi
tput setaf 2; cat $file;
#echo "<h4>Available Buckets </h4>">>out.html
for i in $(cat $file); do echo "<li>$i">>out.html; done
echo "</div></div></div></div>">>out.html
#echo $'\n';
}

#finds vulnerable buckets
function findvulnbuckets() {
	#aws s3api get-public-access-block --bucket $bucket >tmp.txt 2>&1 --ignore
	if aws s3api get-public-access-block --bucket $bucket 2>&1|grep -q -i -e 'false' -e 'NoSuchPublicAccessBlockConfiguration'; then
		echo $bucket>> ~/.objectify-s3/vulnbuckets.txt
		echo "$(tput bold)$(tput setaf 1)Found:$(tput sgr 0) $bucket"
		echo "<li>$bucket</li>">>out.html
	fi
}

#Calls another function find misconfigured buckets
function printmisconfbuckets () {
echo $'\n'"$(tput smso)$(tput setaf 172)Finding misconfigured buckets. It takes a few seconds..$(tput sgr 0)"$'\n'
#echo "<h4>Misconfigured Buckets</h4>">>out.html
echo '<div class="panel-group" id="accordion"><div class="panel panel-default"><div class="panel-heading"><a data-toggle="collapse" data-parent="#accordion" href="#misconfigured"><h4 class="panel-title" style="color:#FF6010;">Misconfigured Buckets</h4></a></div><div id="misconfigured" class="panel-collapse collapse"><div class="panel-body" style="color:#FF6010;">'>>out.html
for bucket in `cat $file` 
do
	#this function checks vulnerable buckets from all buckets
	findvulnbuckets &
done && wait
echo "</div></div></div></div>">>out.html
}

#this function checks for vulnerable objects from file vulnbuckets.txt
function findvulnobj() {
regionparam=`aws s3api get-bucket-location --bucket $bucket| grep -i 'constraint'| cut -d'"' -f4`
if [ -z $regionparam ]; then region="us-east-1"; else region=$regionparam; fi
bundle exec ruby vulnobj.rb $bucket $region 2>/dev/null
}
	
	printbanner; checkupdates; checkaws; 
	echo '<html><head><meta name="viewport" content="width=device-width, initial-scale=1">' >>out.html
	echo "<style>.panel-title:after {content: '\02795';font-size: 13px;color: white;float: right;margin-left: 5px;}</style>">>out.html
	echo '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"><script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script><script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script></head><body><div><i><a href="https://github.com/emgaurav/objectify-s3"><h1 style="padding:20px;background: #343231;font-family: Arial; margin: 0; color: white;font-size: 30px;";>objectify-s3</h1></a></i><br><div><div style="margin-left: 30px">' >>out.html
	listbuckets; printmisconfbuckets; 
	echo $'\n'"$(tput bold)$(tput setab 7)$(tput setaf 1)Listing public objects from all buckets now $(tput sgr 0)"$'\n'
	echo '<h3 style="background-color: #494949;padding: 1rem;border-top: #FA7979 0.25rem solid;border-bottom: #FA7979 0.25rem solid;border-radius: 0.1875rem;color:white;">Public Objects Found  ▼</h3>'>>out.html
	for bucket in `cat ~/.objectify-s3/vulnbuckets.txt`
	do
		echo $'\n'"$(tput bold)$(tput setaf 1)Bucket - > $bucket $(tput sgr 0)";
		findvulnobj;
		tmpfile=~/objectify-s3/tmp.html
		if [ -f $tmpfile ]; then
			echo '<div class="panel-group" id="accordion"><div class="panel panel-default"><div class="panel-heading"><a data-toggle="collapse" data-parent="#accordion" href="#'$bucket'"><h4 class="panel-title" style="color:Red;">'$bucket'</h4></a></div><div id="'$bucket'" class="panel-collapse collapse"><div class="panel-body" style="color:Tomato;">'>>out.html
			cat tmp.html >> out.html 2>/dev/null
			rm tmp.html 2>/dev/null
			echo "</div></div></div></div>">>out.html
		fi


	done
	echo "</div>">>out.html
	open ~/objectify-s3/out.html

echo $'\n'"$(tput smso) $(tput setaf 2) <<<<<<<<<<<<<<  COMPLETED  >>>>>>>>>>>>>> $(tput sgr 0)"$'\n'
