variable "instance-name" {
  default = "data-processor"
}

variable "container-image-uri" {
  default = "gcr.io/cloudrun/hello"
}

variable "location" {
  type = string
}
