output "integration_name" {
  value = "${module.integration.integration_name}"
}

output "send_agentless_email_action_name" {
  value = "${genesyscloud_integration_action.send_agentless_email_action.name}"
}

