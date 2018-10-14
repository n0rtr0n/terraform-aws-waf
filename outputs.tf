output "web_acl_id" {
  value = "${aws_wafregional_web_acl.WAFWebACL.id}"
}

output "WAFList1Id" {
  value = "${aws_wafregional_ipset.WAFReputationListsSet1.id}"
}

output "WAFList2Id" {
  value = "${aws_wafregional_ipset.WAFReputationListsSet2.id}"
}
