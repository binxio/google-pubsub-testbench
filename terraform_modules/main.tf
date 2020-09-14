module "app-forwarder" {
  source     = "./app-forwarder"
  location   = var.location
  project-id = var.project-id

  container-image-uri = var.app-forwarder-container-image-uri
}

module "data-processor" {
  source     = "./data-processor"
  location   = var.location
  project-id = var.project-id

  container-image-uri = var.data-processor-container-image-uri
}

# ! this way, pubsub will now depend on cloud-run. Make sure to prevent any future circular/spiral dependencies !
module "pubsub" {
  source = "./pubsub"

  app-forwarder-email  = module.app-forwarder.email
  app-forwarder-name   = module.app-forwarder.name
  data-processor-email = module.data-processor.email
  data-processor-url   = module.data-processor.url

  user-account-for-pulling = var.user-account-for-pulling
  location                 = var.location
  project-id               = var.project-id
}
