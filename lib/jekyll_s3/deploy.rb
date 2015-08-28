# follow these instructions to setup your bucket:
# http://docs.amazonwebservices.com/AmazonS3/latest/dev/WebsiteHosting.html
# Customize values in _config_s3.yml as appropriate.

require 'aws-sdk'
require 'mime/types'
require 'yaml'

S3_CONFIG_FILE = "_config_s3.yml" # location of file with S3 access key, private key, bucket name

# Use deploy_s3[.*html] to upload only HTML files since the timestamp matching
# doesn't really work well. Most files get re-generated even if they haven't
# changed.
# See http://docs.aws.amazon.com/sdkforruby/api/Aws/S3.html
class JekyllS3::DeployCommand < Jekyll::Command
  class << self    
    def init_with_program prog
      prog.command(:deploy_s3) do |c|
        c.syntax "deploy_s3 [options]"
        c.description 'Upload the site to Amazon S3.'

        c.option 'include', '-i include_pattern', 'File pattern to include.'
        c.option 'force', '-f', 'Force all files to be re-uploaded'

        c.action do |args, options|
          s3_upload options['include'], options['force']
        end
      end
    end

    def s3_upload file_glob, force
      config = YAML.load File.open '_config.yml'
      
      begin
        s3_config = YAML.load File.open S3_CONFIG_FILE
        Aws.config.update(
          credentials: Aws::Credentials.new(
            s3_config['access_key'],
            s3_config['secret_key']
          ),
          region: config['s3']['region'] || 'us-east-1',
        )        
      rescue Exception => e
        puts "Error: #{e}"
        puts "Please verify your AWS credentials in '#{S3_CONFIG_FILE}'"
        return
      end

      public_dir = config['destination'] || '_site'
      file_glob ||= '.*'

      bucket = config['s3']['bucket']
      s3 = Aws::S3::Client.new

      Dir.glob("#{public_dir}/**/*") do |f|

        next if File.directory? f
        f_name = f.sub "#{public_dir}/", ""
        next unless f_name.match( file_glob ) != nil

        # compare atime for each file, only sync changes
        local_modified = Time.at File.stat( f ).mtime
        existing = begin
                     s3.head_object bucket: bucket, key: f_name
                   rescue Aws::S3::Errors::NotFound
                     nil  # file doesn't exist already on S3, no prob
                   end

        if force or not existing or existing.last_modified < local_modified
          puts "Pushing #{f_name} to #{bucket}..."
          s3.put_object key: f_name,
                        bucket: bucket,
                        body: File.new(f,'r'),
                        acl: "public-read",
                        cache_control: config['s3']['cache_control'],
                        content_type: MIME::Types.type_for(f_name).first.content_type
        end
      end
    rescue Aws::Errors::ServiceError => e
      puts "AWS error: #{e.class}"
    end
  end
end
