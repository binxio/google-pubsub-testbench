##### input variables #####

# functional #

variable "app-forwarder-email" {
  type = string
}

variable "data-processor-email" {
  type = string
}

# project #

variable "project-id" {
  type = string
}

variable "location" {
  type = string
}

##### normal variables (that can be declared here, closer to the resource) #####

variable "topic" {
  default = {
    name      = "request-topic"
    publisher = ["publisher-1"]
    subscriptions = {
      subscription-1 = ["subscriber-1"]
    }
  }
}
