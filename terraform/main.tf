# The Trigger configuration that will kick off the workflow
resource "genesyscloud_processautomation_trigger" "customer_leave_trigger" {
  name             = "Customer Leave WebMessage Trigger"
  description      = "When customer leaves a webmessage trigger workflow that will check for unread messages."
  topic_name       = "v2.webmessaging.deployments.{id}.undelivered.messages"
  enabled          = true
  delay_by_seconds = var.trigger_delay_in_seconds
  target {
    id   = module.workflow.workflow_id
    type = "Workflow"
  }
  match_criteria = jsonencode([
    {
      "jsonPath" : "messageType",
      "operator" : "Equal",
      "value" : "WEBMESSAGING"
    }
  ])
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
  get_failed_messages_action_name = module.data_actions.get_failed_messages_action_name
  send_agentless_email_action_name = module.data_actions.send_agentless_email_action_name

  outbound_email_address = var.email_address
  email_subject = "Missed Messages"
  email_body = "You missed some messages from Super Company."
}
