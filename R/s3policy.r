cloudtrail_s3policy <- function(bucket, account_id, prefix = NULL) {
toJSON(fromJSON(paste0('{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck20131101",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::903692715234:root",
          "arn:aws:iam::859597730677:root",
          "arn:aws:iam::814480443879:root",
          "arn:aws:iam::216624486486:root",
          "arn:aws:iam::086441151436:root",
          "arn:aws:iam::388731089494:root",
          "arn:aws:iam::284668455005:root",
          "arn:aws:iam::113285607260:root",
          "arn:aws:iam::035351147821:root"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::',bucket,'"
    },
    {
      "Sid": "AWSCloudTrailWrite20131101",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::903692715234:root",
          "arn:aws:iam::859597730677:root",
          "arn:aws:iam::814480443879:root",
          "arn:aws:iam::216624486486:root",
          "arn:aws:iam::086441151436:root",
          "arn:aws:iam::388731089494:root",
          "arn:aws:iam::284668455005:root",
          "arn:aws:iam::113285607260:root",
          "arn:aws:iam::035351147821:root"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::',bucket,if(!is.null(prefix)) paste0("/", prefix) else "",'/AWSLogs/',account_id,'/*",
      "Condition": { 
        "StringEquals": { 
          "s3:x-amz-acl": "bucket-owner-full-control" 
        }
      }
    }
  ]
}')))
}
