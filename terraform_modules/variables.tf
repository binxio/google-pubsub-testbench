##### project #####

variable "project-id" {
  default = "speeltuin-teindevries"
}

variable "location" {
  default = "europe-west4"
}

##### provider #####
provider "google" {
  # get this from env?
  credentials = file("/Users/tdevries/Work/Projects/BinxInternal/cloudcontrol/google-pubsub-testbench/terraform_modules/secrets/speeltuin-teindevries_service_account_secret_key.json")
  project     = "speeltuin-teindevries"
  region      = var.location
}
