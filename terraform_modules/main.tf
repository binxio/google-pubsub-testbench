module "app-forwarder" {
  source   = "./app-forwarder"
  location = var.location
}

module "data-processor" {
  source   = "./data-processor"
  location = var.location
}

# ! this way, pubsub will now depend on cloud-run. Make sure to prevent any future circular/spiral dependencies !
module "pubsub" {
  source = "./pubsub"

  app-forwarder-email  = module.app-forwarder.email
  data-processor-email = module.data-processor.email
  data-processor-url   = module.data-processor.url

  user-account = var.user-account
  location     = var.location
  project-id   = var.project-id
}
