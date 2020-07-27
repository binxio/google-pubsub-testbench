##### specify #####
variable "CREDENTIALS_KEY_PATH" {
  type = string
}

##### project #####

variable "project-id" {
  default = "speeltuin-teindevries"
}

variable "location" {
  default = "europe-west4"
}

variable "user-account" {
  default = "teindevries@binx.io"
}

##### provider #####
provider "google" {
  # get this from env?
  credentials = var.CREDENTIALS_KEY_PATH
  project     = "speeltuin-teindevries"
  region      = var.location
}
