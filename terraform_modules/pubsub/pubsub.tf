##### Pub/Sub #####

resource "google_project_service" "pubsub-service" {
  project = var.project-id
  service = "pubsub.googleapis.com"
  # disable_dependent_services = true
  disable_on_destroy = false
}
