##### project #####

variable "project-id" {
  type = string
}

variable "location" {
  type = string
}

variable "user-account-for-pulling" {
  type = string
}

variable "app-forwarder-container-image-uri" {
  type = string
}

variable "data-processor-container-image-uri" {
  type = string
}


##### provider #####
provider "google" {
  project = var.project-id
  region  = var.location
}
