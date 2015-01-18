cloudtrailHTTP <- function(query, body = NULL, region, key, secret, ...) {
    if(missing(region))
        region <- "us-east-1"
    if(missing(key))
        key <- Sys.getenv("AWS_ACCESS_KEY_ID")
    if(missing(secret))
        secret <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
    url <- paste0("https://cloudtrail.",region,".amazonaws.com")
    d_timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
    if(key == "") {
        H <- add_headers(`x-amz-date` = d_timestamp)
    } else {
        S <- signature_v4_auth(
               datetime = d_timestamp,
               region = region,
               service = "cloudtrail",
               verb = "POST",
               action = "/",
               query_args = query,
               canonical_headers = list(host = paste0("cloudtrail.",region,".amazonaws.com"),
                                        `x-amz-date` = d_timestamp),
               request_body = "",
               key = key, secret = secret)
        H <- add_headers(`x-amz-date` = d_timestamp, 
                         `x-amz-content-sha256` = S$BodyHash,
                         Authorization = S$SignatureHeader)
    }
    r <- POST(url, H, query = query, ...)
    if(http_status(r)$category == "client error") {
        x <- try(fromJSON(content(r, "text"))$Error, silent = TRUE)
        warn_for_status(r)
        h <- headers(r)
        out <- structure(x, headers = h, class = "aws-error")
        attr(out, "request_canonical") <- S$CanonicalRequest
        attr(out, "request_string_to_sign") <- S$StringToSign
        attr(out, "request_signature") <- S$SignatureHeader
    } else {
        out <- try(fromJSON(content(r, "text")), silent = TRUE)
        if(inherits(out, "try-error"))
            out <- structure(content(r, "text"), "unknown")
    }
    return(out)
}
