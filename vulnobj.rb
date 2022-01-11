# find_public_s3_objects.rb
require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require 'thread/pool'

BUCKET = ARGV[0] or raise("expected bucket name")

s3 = Aws::S3::Resource.new(region: ARGV[1])
region = ARGV[1]

count = 0
comp = 500
pool = Thread.pool 50
mutex = Mutex.new
s3.bucket(BUCKET).objects.each do |object|
  pool.process do
    grants = object.acl.grants
    mutex.synchronize do
      count += 1
      if count % comp == 0
        $stdout.write "Objects Scanned : #{count}"
        string = " - Press Ctrl +  \\ to skip scanning this directory"
        puts string
        comp = comp * 2
        
      end
    end
    if grants.map { |x| x.grantee.uri }.any? { |x| x =~ /AllUsers|AuthenticatedUsers/ }
      mutex.synchronize do
        puts " ⭕ https://#{BUCKET}.s3.#{region}.amazonaws.com/"+object.key
        File.open("tmp.html","a") do |f|
        f.puts "<li><a href=\"https://#{BUCKET}.s3.#{region}.amazonaws.com/"+object.key+"\">/"+object.key+"</a></li>"
        end
      end
    end
  end
end

pool.shutdown
