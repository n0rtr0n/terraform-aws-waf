variable ACCESS_LOG_BUCKET {}
variable AWS_PROFILE {}
variable AWS_REGION {}
variable ENVIRONMENT {}
variable ERROR_THRESHOLD {
  default = 50
}
variable INCLUDE_BAD_BOT_PROTECTION {
  default = true
}
variable INCLUDE_BLACKLIST_SET {
  default = true
}
variable INCLUDE_LOG_PARSER {
  default = true
}
variable INCLUDE_REPUTATION_LISTS {
  default = true
}
variable INCLUDE_SCANS_PROBES_SET {
  default = true
}
variable INCLUDE_SQL_INJECTION_DETECTION {
  default = true
}
variable INCLUDE_WHITELIST_SET {
  default = true
}
variable INCLUDE_XSS_DETECTION {
  default = true
}
variable SEND_ANONYMOUS_USAGE_DATA {
  default = false
}
variable WAF_BLOCK_PERIOD {
  default = 240
}
variable WAF_TYPE {
  default = "alb" #should only be alb or cloudfront
}