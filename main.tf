resource "aws_wafregional_ipset" "WAFWhitelistSet" {
  name  = "Whitelist Set"
  count = "${var.INCLUDE_WHITELIST_SET}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_ipset" "WAFBlacklistSet" {
  name  = "Blacklist Set"
  count = "${var.INCLUDE_BLACKLIST_SET}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_ipset" "WAFScansProbesSet" {
  name  = "Scans Probes Set"
  count = "${var.INCLUDE_SCANS_PROBES_SET}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_ipset" "WAFReputationListsSet1" {
  name  = "IP Reputation Lists Set #1"
//  count = "${var.INCLUDE_REPUTATION_LISTS}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_ipset" "WAFReputationListsSet2" {
  name  = "IP Reputation Lists Set #2"
//  count = "${var.INCLUDE_REPUTATION_LISTS}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_ipset" "WAFBadBotSet" {
  name  = "IP Bad Bot Set"
  count = "${var.INCLUDE_BAD_BOT_PROTECTION}"

  ip_set_descriptor {
    type  = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_sql_injection_match_set" "WAFSqlInjectionDetection" {
  name = "SQL injection Detection"
  count = "${var.INCLUDE_SQL_INJECTION_DETECTION}"

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
      data = "none"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }
}

resource "aws_wafregional_xss_match_set" "WAFXssDetection" {
    name = "XSS Detection Detection"
    count = "${var.INCLUDE_XSS_DETECTION}"

    xss_match_tuple {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "QUERY_STRING"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "QUERY_STRING"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "BODY"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "BODY"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "URI"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "URI"
            data = "none"
        }
    }
    xss_match_tuple {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "HEADER"
            data = "Cookie"
        }
    }
    xss_match_tuple {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "HEADER"
            data = "Cookie"
        }
    }
}