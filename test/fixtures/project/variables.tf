variable "billing_account" {
  description = "The ID of the billing account to which resource costs will be charged."
  type        = string
}

variable "folder_id" {
  default     = ""
  description = "The ID of the folder in which projects will be provisioned."
  type        = string
}

variable "org_id" {
  description = "The ID of the organization in which resources will be provisioned."
  type        = string
}
