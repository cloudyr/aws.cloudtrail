library("testthat")
k1 <- Sys.getenv("AWS_ACCESS_KEY_ID")
k2 <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
if ((k1 != "") && (k2 != "")) {
    library("aws.cloudtrail")
    test_check("aws.cloudtrail")
}
