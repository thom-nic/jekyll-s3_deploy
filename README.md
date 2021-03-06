# Jekyll S3 Deploy Command

Publish your Jekyll site to Amazon S3.  This is a pure-ruby solution that uses
on `aws-sdk`, as opposed to `s3_website` which relies on a Java JAR.

Follow [these instructions](http://docs.amazonwebservices.com/AmazonS3/latest/dev/WebsiteHosting.html)
to setup your Amazon AWS bucket as appropriate.  You also probably want to
[setup your own domain](http://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) although this process has no bearing on the actual upload/
serving files from S3.

## Installation and Usage

Add this line to your Jekyll project's Gemfile:

```ruby
group :jekyll_plugins do
  gem 'jekyll-s3_deploy', github: 'thom-nic/jekyll-s3_deploy'
end
```

Then run `bundle install`.  Add a `_config_s3.yml` file with the following:
```yaml
# S3 access credentials
# Add this file to your .gitignore!!!
access_key: your access key
secret_key: your secret key
```

And add the following to `_config.yml`
```yaml
s3:
  bucket: mysite.com
  region: us-east-1   # optional, this is the default value
  cache_control:      # Cache-Control headers (optional)
    'assets/*' : max-age=3600
    '*.html' : max-age=300
  deflate:            # what assets should be Content-Encoded (optional)
    - '*.html'
    - '*.css'
    - '*.svg'
```

And then execute:

```bash
jekyll deploy_s3
```

If you use the [Jekyll sitemap plugin](https://github.com/jekyll/jekyll-sitemap),
this project also contains a `ping` command to notify Google and Bing web
crawlers that your site has been updated.  Just run `jekyll ping`

### Options

`-f` - Force upload everything under `_site`


### More details on setting up your AWS credentials...

This is the one bit that's difficult to remember/ not explained well in the
AWS docs.  When you create your IAM user, this is the policy you need:

```javascript
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::mysite.com",
        "arn:aws:s3:::mysite.com/*"
      ]
    }
  ]
}
```
*(of course, replace mysite.com with your domain)*

## To Do

* Document command options
* Add CloudFront support
* Add gzip content-encoding support
