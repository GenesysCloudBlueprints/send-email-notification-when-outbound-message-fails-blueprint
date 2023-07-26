resource "genesyscloud_flow" "send_email_workflow" {
  filepath          = "${path.module}/SendEmailWorkflow.yaml"
  file_content_hash = filesha256("${path.module}/SendEmailWorkflow.yaml")
  substitutions = {
    flow_name                   = "Send Email on Failed WebMessage Workflow"
    gc_data_actions_integration = var.integration_name
    get_failed_messages_action  = var.get_failed_messages_action_name
    send_agentless_email_action = var.send_agentless_email_action_name
    from_email                  = var.outbound_email_address
    email_subject               = var.email_subject
    email_body                  = var.email_body
    external_contact_email_type = var.external_contact_email_type
    division                    = "Home"
    language                    = "en-us"
  }
}
