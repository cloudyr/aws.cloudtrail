% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/policies.R
\name{cloudtrail_s3policy}
\alias{cloudtrail_s3policy}
\alias{cloudtrail_snspolicy}
\title{Example Policies for CloudTrail}
\usage{
cloudtrail_s3policy(bucket, account_id, prefix = NULL)

cloudtrail_snspolicy(topic)
}
\arguments{
\item{bucket}{A character string containing an S3 bucket name, or an object of class \dQuote{s3_bucket}.}

\item{account_id}{A character string containing an AWS account ID.}

\item{prefix}{Optionally, a character string containing the prefix for the Account ID. This can be retrieved from the AWS console or via a call to \code{aws.iam::get_caller_identity()}.}

\item{topic}{A character string specifying the SNS topic ARN.}
}
\value{
A character string containing the policy
}
\description{
Construct an S3 or SNS policy document for use with CloudTrail
}
