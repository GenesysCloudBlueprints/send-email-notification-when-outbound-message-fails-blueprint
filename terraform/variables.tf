variable "client_id" {
  type        = string
  description = "The OAuth (Client Credentails) Client ID to be used by Data Actions"
}

variable "client_secret" {
  type        = string
  description = "The OAuth (Client Credentails) Client Secret to be used by Data Actions"
}

variable "email_address" {
  type        = string
  description = "The email address used for sending an agentless outbound email"
}

variable "trigger_delay_in_seconds" {
  type        = number
  description = "The amount of delay in seconds before executing the trigger."
  default     = null
}
