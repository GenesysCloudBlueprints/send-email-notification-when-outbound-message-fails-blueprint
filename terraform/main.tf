resource "genesyscloud_integration" "gc_integration" {
  intended_state   = "ENABLED"
  integration_type = "purecloud-data-actions"
  config {
    name        = "Send Outbound Email on Failed Messages Integration"
    notes       = "Genesys Cloud Integration containing the actions for sending outbound email on failed webmessages"
    credentials = {
      pureCloudOAuthClient = genesyscloud_integration_credential.gc_integration_credential.id
    }
  }
}

resource "genesyscloud_integration_credential" "gc_integration_credential" {
  name                 = "GC Integration Credential"
  credential_type_name = "pureCloudOAuthClient" 
  fields = {
    clientId = "2fc45972-0302-4a7a-b6b1-e83784579922"
    clientSecret = "wYEgcojWmk_tXPEq2l-9THSDLOdRGIW3ug9LLkvBz5A"
  }
}

resource "genesyscloud_integration_action" "get_failed_messages_action" {
  name                   = "Get Failed Delivery Messages"
  category               = genesyscloud_integration.gc_integration.config[0].name
  integration_id         = genesyscloud_integration.gc_integration.id
  contract_input = jsonencode({
    "type" = "object",
    "required" = [
      "CONVERSATION_ID"
    ],
    "properties" = {
      "CONVERSATION_ID" = {
        "type" = "string"
      }
    }
  })
  contract_output = jsonencode({
    "type" = "object",
    "required" = [
      "FAILED_DELIVERY"
    ],
    "properties" = {
      "FAILED_DELIVERY" = {
        "type" = "string"
      }
    }
  })
  config_request {
    request_url_template = "/api/v2/conversations/$${input.CONVERSATION_ID}"
    request_type         = "GET"
    request_template     = "$${input.rawRequest}"
    headers = {
      Cache-Control = "no-cache"
      Content-Type  = "application/x-www-form-urlencoded"
    }
  }
  config_response {
    translation_map = {
      FAILED_DELIVERY = "$.participants[?(@.purpose == 'agent')].messages[0].messages[?(@.messageStatus == 'delivery-failed')].messageId"
    }
    translation_map_defaults = { }
    success_template = "{\n \"FAILED_DELIVERY\": $${successTemplateUtils.firstFromArray(\"$${FAILED_DELIVERY}\")}\n}"
  }
}

resource "genesyscloud_integration_action" "send_agentless_email_action" {
  name                   = "Send Agentless Email"
  category               = genesyscloud_integration.gc_integration.config[0].name
  integration_id         = genesyscloud_integration.gc_integration.id
  contract_input = jsonencode({
    "type" = "object",
    "required" = [
      "FROM_EMAIL", "TO_EMAIL", "SUBJECT", "BODY", "SENDER_TYPE"
    ],
    "properties" = {
      "FROM_EMAIL" = {
        "type" = "string"
      },
      "TO_EMAIL" = {
        "type" = "string"
      },
      "SUBJECT" = {
        "type" = "string"
      },
      "BODY" = {
        "type" = "string"
      },
      "SENDER_TYPE" = {
        "type" = "string"
      }
    }
  })
  contract_output = jsonencode({
    "type" = "object",
    "required" = [
      "ID", "CONVERSATION_ID"
    ],
    "properties" = {
      "ID" = {
        "type" = "string"
      },
      "CONVERSATION_ID" = {
        "type" = "string"
      }
    }
  })
  config_request {
    request_url_template = "/api/v2/conversations/emails/agentless"
    request_type         = "POST"
    request_template     = "{\"senderType\": \"$${input.SENDER_TYPE}\", \"fromAddress\" : {\"email\": \"$${input.FROM_EMAIL}\"}, \"toAddresses\" : [{\"email\": \"$${input.TO_EMAIL}\"}], \"subject\" : \"$${input.SUBJECT}\", \"textBody\" : \"$${input.BODY}\"}"
    headers = {
      Cache-Control = "no-cache"
      Content-Type  = "application/json"
      UserAgent     = "PureCloudIntegrations/1.0"
    }
  }
  config_response {
    translation_map = {
      "CONVERSATION_ID" = "$.conversationId",
      "ID"              = "$.id"
    }
    translation_map_defaults = { }
    success_template = "{\n   \"ID\": $${ID}, \"CONVERSATION_ID\": $${CONVERSATION_ID}\n}"
  }
}

resource "genesyscloud_flow" "send_email_workflow" {
  filepath          = "./SendEmailWorkflow.yaml"
  file_content_hash = filesha256("./SendEmailWorkflow.yaml")
  substitutions = {
    flow_name                   = "Send Email on Failed WebMessage Workflow"
    gc_data_actions_integration = genesyscloud_integration.gc_integration.config[0].name
    get_failed_messages_action  = genesyscloud_integration_action.get_failed_messages_action.name
    send_agentless_email_action = genesyscloud_integration_action.send_agentless_email_action.name
    from_email                  = "prince_tf@outbound.devfoundry.link"
    external_contact_email_type = "personalEmail" // or workEmail
    email_subject               = "Missed Messages"
    email_body                  = "You missed some chat messages from Super Company"
    division                    = "Home"
    language                    = "en-us"
  }
}

resource "genesyscloud_processautomation_trigger" "customer_leave_trigger" {
  name        = "Customer Leave WebMessage Trigger"
  description = "When customer leaves a webmessage trigger workflow that will check for unread messages."
  topic_name  = "v2.detail.events.conversation.{id}.customer.end"
  enabled     = true
  target {
    id   = genesyscloud_flow.send_email_workflow.id
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
