resource "aws_wafregional_rule" "WAFWhitelistRule" {
  name        = "Whitelist Rule"
  count       = "${var.INCLUDE_WHITELIST_SET}"
  metric_name = "SecurityAutomationsWhitelistRule"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFWhitelistSet.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFBlacklistRule" {
  name        = "Blacklist Rule"
  count       = "${var.INCLUDE_BLACKLIST_SET}"
  metric_name = "SecurityAutomationsBlacklistRule"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFBlacklistSet.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFScansProbesRule" {
  name        = "Scans Probes Rule"
  count       = "${var.INCLUDE_SCANS_PROBES_SET}"
  metric_name = "SecurityAutomationsScansProbesRule"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFScansProbesSet.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFIPReputationListsRule1" {
  name        = "WAF IP Reputation Lists Rule #1"
  count       = "${var.INCLUDE_REPUTATION_LISTS}"
  metric_name = "SecurityAutomationsIPReputationListsRule1"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFReputationListsSet1.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFIPReputationListsRule2" {
  name        = "WAF IP Reputation Lists Rule #2"
  count       = "${var.INCLUDE_REPUTATION_LISTS}"
  metric_name = "SecurityAutomationsIPReputationListsRule2"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFReputationListsSet2.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFBadBotRule" {
  name        = "Bad Bot Rule"
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  metric_name = "SecurityAutomationsBadBotRule"

  predicate {
    data_id = "${aws_wafregional_ipset.WAFBadBotSet.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rule" "WAFSqlInjectionRule" {
  name        = "SQL Injection Rule"
  count       = "${var.INCLUDE_SQL_INJECTION_DETECTION}"
  metric_name = "SecurityAutomationsSqlInjectionRule"

  predicate {
    data_id = "${aws_wafregional_sql_injection_match_set.WAFSqlInjectionDetection.id}"
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_wafregional_rule" "WAFXssRule" {
  name        = "XSS Rule"
  count       = "${var.INCLUDE_XSS_DETECTION}"
  metric_name = "SecurityAutomationsXssRule"

  predicate {
    data_id = "${aws_wafregional_xss_match_set.WAFXssDetection.id}"
    negated = false
    type    = "XssMatch"
  }
}

