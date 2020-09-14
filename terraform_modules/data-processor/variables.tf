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
  type = string #TODO: generalize by externalizing project-id (tfvars?)
}
