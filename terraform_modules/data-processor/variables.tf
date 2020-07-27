variable "instance-name" {
  default = "data-processor"
}

variable "container-image-uri" {
  default = "gcr.io/speeltuin-teindevries/data-processor"
}

variable "location" {
  type = string
}
