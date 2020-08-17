variable "project-id" {
  type = string
}

variable "location" {
  type = string
}

variable "instance-name" {
  default = "data-processor"
}

variable "container-image-uri" {
  default = "gcr.io/speeltuin-teindevries/data-processor" #TODO: generalize by externalizing project-id (tfvars?)
}
