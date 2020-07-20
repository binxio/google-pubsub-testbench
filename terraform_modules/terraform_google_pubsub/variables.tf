variable "project-id" {
  default = "pubsub-testbench"
}

variable "topic" {
  default = {
    name      = "request-topic"
    publisher = ["publisher-1"]
    subscriptions = {
      subscription-1 = ["subscriber-1"]
    }
  }
}
