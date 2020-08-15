##### input variables #####

# functional #
#TODO anonymize these variables into lists of subscribers, publishers, etc
variable "app-forwarder-email" {
  type = string
}

variable "app-forwarder-name" {
  type = string
}

variable "data-processor-email" {
  type = string
}

variable "data-processor-url" {
  type = string
}

# project #

variable "user-account" {
  type = string
}

variable "project-id" {
  type = string
}

variable "location" {
  type = string
}
