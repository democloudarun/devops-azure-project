variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "ssh_public_key" {}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

