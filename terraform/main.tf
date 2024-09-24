# The Trigger configuration that will kick off the workflow
resource "genesyscloud_processautomation_trigger" "undelivered_webmessages_trigger" {
  name             = "Failed delivery of webmessages Trigger"
  description      = "When webmessage fails to be delivered, trigger workflow that will send email notifications."
  topic_name       = "v2.webmessaging.deployments.{id}.undelivered.messages"
  enabled          = true
  target {
    id   = module.workflow.workflow_id
    type = "Workflow"
    workflow_target_settings {
      data_format = "Json"
    }
  }
  match_criteria = ""
}


# GC Integrations and Data Actions configuration
module "data_actions" {
  source = "./data_actions"
  client_id = var.client_id
  client_secret = var.client_secret
}

# Module for the workflow which sends the actual email
module "workflow" {
  source = "./workflow"
  integration_name = module.data_actions.integration_name
  send_agentless_email_action_name = module.data_actions.send_agentless_email_action_name

  outbound_email_address = var.email_address
  email_subject = "Missed Messages"
  email_body = "You missed some messages from Super Company."
}
