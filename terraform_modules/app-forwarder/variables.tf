variable "project-id" {
  type = string
}

variable "location" {
  type = string
}

variable "instance-name" {
  default = "app-forwarder"
}

variable "container-image-uri" {
  default = "gcr.io/speeltuin-teindevries/app-forwarder"
}
