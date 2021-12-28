# objectify-s3
Objectify-s3 is a fully automated scanner that recursively scans all AWS S3 buckets and objects in your AWS account for misconfigured permissions. Unlike most S3 auditing tools that only show bucket policy misconfigurations, this one checks object level ACLs as well, recursively. <br>
Output contains: 
  1. All available buckets for scan
  2. Buckets with misconfigured permission (either bucket is public or objects are public)
  3. Objects(bucket-wise) with public read permission

# Requirements
1. Ruby
2. awscli

# Installation
1. Clone the repository. (Switch to your $Home directory `cd ~` before cloning) <br> `git clone https://github.com/emgaurav/objectify-s3.git`
2. Run the setup. <br> `bash setup.sh` 
3. That's about it.

# Usage
`objectify-s3` <br>
Usage is very simple. No need to pass arguments or files. Simply run `objectify-s3` from any directory in terminal and it will start it's job.
You just have to make sure your `awscli` is working properly and access keys are configured. `objectify-s3` runs with default aws credentials. Profiles are not supported yet.

# Supported Platforms
1. Linux
2. MAC

# Credits/References
https://faraday.ai/blog/finding-public-s3-objects/
