variable "instance-name" {
  default = "app-forwarder"
}

variable "container-image-uri" {
  default = "gcr.io/cloudrun/hello"
}

variable "location" {
  type = string
}
