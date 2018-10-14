#TODO: add rules conditionally OR add aws_wafregional_web_acl_rule resource


resource "aws_wafregional_web_acl" "WAFWebACL" {
  name        = "WebACL-${var.ENVIRONMENT}-1"
  metric_name = "SecurityAutomationsMaliciousRequesters"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rule.WAFWhitelistRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_wafregional_rule.WAFBlacklistRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_wafregional_rule.WAFIPReputationListsRule1.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_wafregional_rule.WAFIPReputationListsRule2.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_wafregional_rule.WAFBadBotRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 70
    rule_id  = "${aws_wafregional_rule.WAFSqlInjectionRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_wafregional_rule.WAFXssRule.id}"
  }
}
