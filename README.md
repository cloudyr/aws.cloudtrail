# AWS CloudTrail Client Package

**aws.cloudtrail** is a simple client package for the Amazon Web Services (AWS) [CloudTrail](http://aws.amazon.com/awscloudtrail/) REST API, which can be used to monitor use of AWS web services API calls by logging API requests in an S3 bucket.

To use the package, you will need an AWS account and enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. 

By default, all **cloudyr** packages look for the access key ID and secret access key in environment variables. You can also use this to specify a default region or a temporary "session token". For example:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```

These can alternatively be set on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`).

If you work with multiple AWS accounts, another option that is consistent with other Amazon SDKs is to create [a centralized `~/.aws/credentials` file](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), containing credentials for multiple accounts. You can then use credentials from this file on-the-fly by simply doing:

```R
# use your 'default' account credentials
aws.signature::use_credentials()

# use an alternative credentials profile
aws.signature::use_credentials(profile = "bob")
```

Temporary session tokens are stored in environment variable `AWS_SESSION_TOKEN` (and will be stored there by the `use_credentials()` function). The [aws.iam package](https://github.com/cloudyr/aws.iam/) provides an R interface to IAM roles and the generation of temporary session tokens via the security token service (STS).

## Code Examples

A CloudTrail is a log of API calls made to AWS. The service is incredibly easy to use. It simply requires creating a trail that defines where (i.e., in what AWS S3 bucket) the CloudTrail log should be stored.

To use CloudTrail, start by creating an S3 bucket. The s3 bucket should exist (perhaps created using **aws.s3**) and have write permissions granted to CloudTrail. An example permission document is provided by `cloudtrail_s3policy()`. This can be done using the **aws.s3** package:

```R
library("aws.s3")

# create bucket
mybucket <- "my1stcloudtrailbucket"
stopifnot(put_bucket(mybucket))

# attach CloudTrail policy to bucket
ctpolicy <- cloudtrail_s3policy(mybucket, "my_aws_id")
stopifnot(put_bucket_policy(mybucket, policy = ctpolicy))
```

Note: CloudTrail appears to be very picky about bucket naming. The bucket name should be lowercase ASCII characters, without special characters.

```R
library("aws.cloudtrail")
trail <- create_trail(name = "NewTrail", bucket = mybucket)
get_trails() # see trail in list of trails
```

Once a trail is created, it can be updated (e.g., to move it to a different bucket, to activate event notifications using SNS, etc.) using `update_trail()`.

```R
# move trail to another bucket
otherbucket <- "myotherexamplebucket"
stopifnot(put_bucket(otherbucket))
ctpolicy <- cloudtrail_s3policy(otherbucket, "my_aws_id")
stopifnot(put_bucket_policy(otherbucket, policy = ctpolicy))

update_trail(name = "NewTrail", bucket = otherbucket)

# send SNS notifications when log updated
library("aws.sns")
top <- create_topic("MyCloudTrailTopic")
set_topic_attrs(top, list(Policy = cloudtrail_snspolicy(top)))
update_trail(name = "NewTrail", sns_topic = top)

# log global calls (e.g., IAM)
update_trail(name = "NewTrail", global = TRUE)
```

Once created and configured, it is easy to start logging requests using `start_logging()` and stop logging using `stop_logging()`:

```R
start_logging(trail)
trail_status(trail)$IsLogging # check logging status
stop_logging(trail)
```

The log is simply an S3 object, saved in the named bucket. We can check for logs using `get_bucket()` and retrieve one of the logs as a data frame using `get_object()`:

```R
(objects <- get_bucket(otherbucket))
mylog <- rawConnection(get_object(objects[[2]]))
jsonlite::fromJSON(mylog)
```

If you're done with a trail, you can delete it and it will no longer show up in your trail list:

```R
delete_trail(trail)
get_trails()
```


## Installation ##

[![CRAN](https://www.r-pkg.org/badges/version/aws.cloudtrail)](https://cran.r-project.org/package=aws.cloudtrail)
![Downloads](https://cranlogs.r-pkg.org/badges/aws.cloudtrail)
[![Build Status](https://travis-ci.org/cloudyr/aws.cloudtrail.png?branch=master)](https://travis-ci.org/cloudyr/aws.cloudtrail)
[![codecov.io](https://codecov.io/github/cloudyr/aws.cloudtrail/coverage.svg?branch=master)](https://codecov.io/github/cloudyr/aws.cloudtrail?branch=master)

This package is not yet on CRAN. To install the latest development version you can install from the cloudyr drat repository:

```R
# latest stable version
install.packages("aws.cloudtrail", repos = c(cloudyr = "http://cloudyr.github.io/drat", getOption("repos")))
```

Or, to pull a potentially unstable version directly from GitHub:

```R
if (!require("ghit")) {
    install.packages("ghit")
}
ghit::install_github("cloudyr/aws.cloudtrail")

---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
