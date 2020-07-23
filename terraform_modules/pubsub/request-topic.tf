##### topics ######

# make for multiple based on list in variables
resource "google_pubsub_topic" "topic" {
  name       = var.topic["name"]
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}


##### publishers #####

# would it be better to make policies out of these?
resource "google_pubsub_topic_iam_member" "publisher" {
  member     = "serviceAccount:${var.api-email}"
  topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.topic]
}


##### subscriptions #####

resource "google_pubsub_subscription_iam_binding" "subscriber" {
  subscription = google_pubsub_subscription.subscription.name
  members = [
    "serviceAccount:${var.data-processor-email}"
  ]
  role       = "roles/pubsub.subscriber"
  depends_on = [google_pubsub_subscription.subscription]
}

resource "google_pubsub_subscription" "subscription" {
  name       = "request-subscription"
  topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
  project    = var.project-id
  depends_on = [google_pubsub_topic.topic]
}
