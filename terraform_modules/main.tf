module "api" {
  source = "./cloud-run"

  instance-name       = "app-interface"
  container-image-uri = "gcr.io/cloudrun/hello"

  location = var.location
}

module "data-processor" {
  source = "./cloud-run"

  instance-name       = "data-processor"
  container-image-uri = "gcr.io/cloudrun/hello"

  location = var.location
}

# ! this way, pubsub will now depend on cloud-run. Make sure to prevent any future circular/spiral dependencies !
module "pubsub" {
  source               = "./pubsub"
  api-email            = module.api.email
  data-processor-email = module.data-processor.email

  location   = var.location
  project-id = var.project-id
}
