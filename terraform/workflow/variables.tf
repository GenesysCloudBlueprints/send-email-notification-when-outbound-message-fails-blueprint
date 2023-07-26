variable "integration_name" {
  type        = string
  description = "The name of the Genesys Cloud Data Actions Integration"
}

variable "get_failed_messages_action_name" {
  type        = string
  description = "The name of the GC Data Action for getting failed messages on a conversation"
}

variable "send_agentless_email_action_name" {
  type        = string
  description = "The name of the GC Data Action for sending an agentless outbound email"
}

variable "outbound_email_address" {
  type        = string
  description = "Email address to use for outbound messaging."
}

variable "email_subject" {
  type        = string
  description = "Subject of the outbound email sent"
}

variable "email_body" {
  type        = string
  description = "Body of the outbound email sent"
}

variable "external_contact_email_type" {
  type        = string
  description = "Email property of External Contact to send outbound email to. 'personalEmail' or 'workEmail'."
  default     = "personalEmail"
}
