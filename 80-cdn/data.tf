data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_cache_policy" "cacheEnable" {
  name = "Managed-CachingOptimized"
}
data "aws_ssm_parameter" "https_certificate_arn" {  //https cetificate arn , web_alb_certificate arn both are same
  name = "/${var.project_name}/${var.environment}/https_certificate_arn"          # the above name https_certificate_arn , this web_alb_certificate_arn both may have different names also.for understanding purpose evrytime we are giving same names
}