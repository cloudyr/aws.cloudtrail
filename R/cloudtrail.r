#' @rdname trails
#' @title Trails
#' @description Create, update, or delete a Cloudtrail
#' @details
#' \code{create_trail} sets up a trail to log requests into a specified S3 bucket. A maximum of five trails can exist in a region.
#' \code{update_trail} can update specific details for a trail. The trail can be active at the time.
#' \code{delete_trail} deletes a trail.
#' @template name
#' @param bucket A character string specifying the name of an S3 bucket to deposit Cloudtrail logs into. AWS recommends this be a dedicated bucket exclusively for Cloudtrail logs. In order to succeed, the bucket must have an appropriate policy (see \href{http://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html}{documentation}).
#' @param log_group Optionally, a character string specifying a log group name using an Amazon Resource Name (ARN), a unique identifier that represents the log group to which CloudTrail logs will be delivered. 
#' @param log_role Optionally, a character string specifying the role for the CloudWatch Logs endpoint to assume to write to a user's log group.
#' @param global Specifies whether the trail is publishing events from global services such as IAM to the log files.
#' @param multi_region A logical specifying whether the trail will cover all regions (\code{TRUE}) or only the region in which the trail is created (\code{FALSE}).
#' @param key_prefix Optionally, a prefix for the log file names created by the trail.
#' @param sns_topic Optionally, a character string specifying an AWS SNS topic, to which notifications will be sent when each new log file is created.
#' @param kms Optionally, a character string specifying a Key Management Service (KMS) key alias (of the form \dQuote{alias/KEYALIAS}) or ARN to be used to encrypt logs.
#' @template dots
#' @return For \code{create_trail} and \code{update_trail}, a list. For \code{delete_trail}, a logical.
#' @seealso \code{\link{get_trails}}, \code{\link{trail_status}}, \code{\link{start_logging}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_CreateTrail.html}
#' @examples
#' \dontrun{
#' trail <- create_trail("exampletrail", "mys3bucket")
#' start_logging("exampletrail")
#' stop_logging("exampletrail")
#' trail_status("exampletrail")
#' delete_trail("exampletrail")
#' get_trails()
#' }
#' @export
create_trail <- 
function(name, bucket, 
         log_group = NULL, 
         log_role = NULL,
         global = FALSE,
         multi_region = FALSE,
         key_prefix = NULL,
         sns_topic = NULL,
         kms = NULL,
         ...) {
    query_args <- list(Action = "CreateTrail")
    query_args$Name <- name
    query_args$S3BucketName <- bucket
    if (!is.null(log_group)) {
        query_args$CloudWatchLogsLogGroupArn <- log_group
    }
    if (!is.null(log_role)) {
        query_args$CloudWatchLogsRoleArn <- log_role
    }
    if (!is.null(global)) {
        query_args$IncludeGlobalServiceEvents <- global
    }
    if (!is.null(multi_region)) {
        query_args$IsMultiRegionTrail <- multi_region
    }
    if (!is.null(key_prefix)) {
        if (nchar(key_prefix) > 200) {
            stop("'key_prefix' must be max 200 characters")
        }
        query_args$S3KeyPrefix <- key_prefix
    }
    if (!is.null(sns_topic)) {
        query_args$SnsTopicName <- sns_topic
    }
    if (!is.null(kms)) {
        query_args$KmsKeyId <- kms
    }
    out <- cloudtrailHTTP(query = query_args, ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$CreateTrailResponse$CreateTrailResult,
              RequestId = out$CreateTrailResponse$ResponseMetadata$RequestId,
              class = "aws_cloudtrail")
}

#' @rdname trails
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_UpdateTrail.html}
#' @export
update_trail <- 
function(name, 
         bucket = NULL, 
         log_group = NULL, 
         log_role = NULL,
         global = NULL,
         key_prefix = NULL,
         sns_topic = NULL,
         ...) {
    query_args <- list(Action = "UpdateTrail")
    query_args$Name <- name
    if (!is.null(bucket)) {
        query_args$S3BucketName <- bucket
    }
    if (!is.null(log_group)) {
        query_args$CloudWatchLogsLogGroupArn <- log_group
    }
    if (!is.null(log_role)) {
        query_args$CloudWatchLogsRoleArn <- log_role
    }
    if (!is.null(global)) {
        query_args$IncludeGlobalServiceEvents <- global
    }
    if (!is.null(key_prefix)) {
        query_args$S3KeyPrefix <- key_prefix
    }
    if (!is.null(sns_topic)) {
        query_args$SnsTopicName <- sns_topic
    }
    out <- cloudtrailHTTP(query = query_args, ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$UpdateTrailResponse$UpdateTrailResult,
              RequestId = out$UpdateTrailResponse$ResponseMetadata$RequestId,
              class = "aws_cloudtrail")
}

#' @rdname trails
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DeleteTrail.html}
#' @export
delete_trail <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "DeleteTrail", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$DeleteTrailResponse$ResponseMetadata$RequestId)
}

#' @title get_trails
#' @description Get list of trails
#' @details Get a list of available cloudtrails.
#' @template dots
#' @return A list of objects of class \dQuote{aws_cloudtrail}.
#' @seealso \code{\link{create_trail}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DescribeTrails.html}
#' @examples
#' \dontrun{
#' get_trails()
#' }
#' @export
get_trails <- function(...) {
    out <- cloudtrailHTTP(query = list(Action = "DescribeTrails"), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    trail_list <- out$DescribeTrailsResponse$DescribeTrailsResult$trailList
    structure(lapply(trail_list, `class<-`, "aws_cloudtrail"),
              RequestId = out$DescribeTrailsResponse$ResponseMetadata$RequestId)
}

#' @title trail_status
#' @description Get trail status/history
#' @details This function returns full details and history for a trail, including errors and logging start/stop times.
#' @template name
#' @template dots
#' @return A list.
#' @seealso \code{\link{get_trails}}, \code{\link{start_logging}}, \code{\link{create_trail}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_GetTrailStatus.html}
#' @examples
#' \dontrun{
#' trail <- create_trail("exampletrail", "mys3bucket")
#' start_logging("exampletrail")
#' stop_logging("exampletrail")
#' trail_status("exampletrail")
#' delete_trail("exampletrail")
#' }
#' @export
trail_status <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "GetTrailStatus", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$GetTrailStatusResponse$GetTrailStatusResult,
              RequestId = out$GetTrailStatusResponse$ResponseMetadata$RequestId)
}

#' @rdname logging
#' @title logging
#' @description Start/stop logging
#' @details \code{start_logging} starts a 
#' @template name
#' @template dots
#' @seealso \code{\link{create_trail}}, \code{\link{trail_status}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_StartLogging.html}, \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_StopLogging.html}
#' @examples
#' \dontrun{
#' trail <- create_trail("exampletrail", "mys3bucket")
#' start_logging("exampletrail")
#' stop_logging("exampletrail")
#' trail_status("exampletrail")
#' delete_trail("exampletrail")
#' }
#' @export
start_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StartLogging", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StartLoggingResponse$ResponseMetadata$RequestId)
}

#' @rdname logging
#' @export
stop_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StopLogging", Name = name), ...)
     if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StopLoggingResponse$ResponseMetadata$RequestId)
}
