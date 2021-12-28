# find_public_s3_objects.rb
require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require 'thread/pool'

BUCKET = ARGV[0] or raise("expected bucket name")

s3 = Aws::S3::Resource.new(region: ARGV[1])

count = 0
pool = Thread.pool 16
mutex = Mutex.new
s3.bucket(BUCKET).objects.each do |object|
  pool.process do
    grants = object.acl.grants
    mutex.synchronize do
      count += 1
      if count % 500 == 0
        $stderr.write "#{count} and counting..Too many objects here.."
        string = "Press Ctrl +  \\ to skip the current directory"
        puts string
        
      end
    end
    if grants.map { |x| x.grantee.uri }.any? { |x| x =~ /AllUsers/ }
      mutex.synchronize do
        puts "Object - > "+object.key
      end
    end
  end
end

pool.shutdown
