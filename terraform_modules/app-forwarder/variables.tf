

variable "request-topic-name" {
  default = "request-topic"
}

variable "instance-name" {
  default = "app-forwarder"
}

variable "container-image-uri" {
  default = "gcr.io/speeltuin-teindevries/app-forwarder"
  # default = "gcr.io/cloudrun/hello"
}

variable "location" {
  type = string
}
