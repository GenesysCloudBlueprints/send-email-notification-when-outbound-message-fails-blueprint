module "integration" {
    source = "git::https://github.com/GenesysCloudDevOps/public-api-data-actions-integration-module.git?ref=v1.0.0"

    integration_name                = "GC Data Actions - Failed Messages Notification"
    integration_creds_client_id     = var.client_id
    integration_creds_client_secret = var.client_secret
}

resource "genesyscloud_integration_action" "send_agentless_email_action" {
  name                   = "Send Agentless Email CX"
  category               = module.integration.integration_name
  integration_id         = module.integration.integration_id
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
    request_template     = "{\"senderType\": \"$${input.SENDER_TYPE}\", \"fromAddress\" : {\"email\": \"$${input.FROM_EMAIL}\"}, \"toAddresses\" : [{\"email\": \"$${input.TO_EMAIL}\"}], \"subject\" : \"$${input.SUBJECT}\", \"textBody\" : \"$esc.jsonString($${input.BODY})\"}"
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
