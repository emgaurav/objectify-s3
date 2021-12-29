# objectify-s3
Objectify-s3 is a fully automated scanner that recursively scans all AWS S3 buckets and objects in your AWS account for misconfigured permissions. Unlike most S3 auditing tools that only show bucket policy misconfigurations, this one checks object level ACLs as well, recursively. <br>
Output contains: 
  1. All available buckets for scan
  2. Buckets with misconfigured permission (either bucket is public or objects are public)
  3. Objects(bucket-wise) with public read permission

# Requirements
1. Ruby
2. awscli
3. Git

# Installation
Use this one liner
```
cd ~; git clone https://github.com/emgaurav/objectify-s3.git; cd objectify-s3; bash setup.sh
```

# Usage
```
objectify-s3
```
Usage is very simple. No need to pass arguments or files. Simply run `objectify-s3` from any directory in terminal and it will start it's job.
`objectify-s3` runs with aws credentials 'default' profile. Custom profiles are not supported yet.

**Press  _Ctrl + \\_  to skip finding objects from current bucket or directory** <br>

# Supported Platforms
1. Linux
2. MAC

# Credits/References
https://faraday.ai/blog/finding-public-s3-objects/
