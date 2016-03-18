#' @export
create_trail <- 
function(name, bucket, 
         log_group = NULL, 
         log_role = NULL,
         global = NULL,
         key_prefix = NULL,
         sns_topic = NULL,
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
    structure(out$CreateTrailResponse$CreateTrailResult,
              RequestId = out$CreateTrailResponse$ResponseMetadata$RequestId)
}

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
              RequestId = out$UpdateTrailResponse$ResponseMetadata$RequestId)
}

#' @export
delete_trail <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "DeleteTrail", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$DeleteTrailResponse$ResponseMetadata$RequestId)
}

#' @export
get_trails <- function(...) {
    out <- cloudtrailHTTP(query = list(Action = "DescribeTrails"), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$DescribeTrailsResponse$DescribeTrailsResult$trailList,
              RequestId = out$DescribeTrailsResponse$ResponseMetadata$RequestId)
}

#' @export
trail_status <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "GetTrailStatus", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$GetTrailStatusResponse$GetTrailStatusResult,
              RequestId = out$GetTrailStatusResponse$ResponseMetadata$RequestId)
}

#' @export
start_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StartLogging", Name = name), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StartLoggingResponse$ResponseMetadata$RequestId)
}

#' @export
stop_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StopLogging", Name = name), ...)
     if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StopLoggingResponse$ResponseMetadata$RequestId)
}
